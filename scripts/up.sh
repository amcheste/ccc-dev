#!/usr/bin/env bash
# Bring up the full CCC stack on a local kind cluster:
# traefik + postgres + every service built from its local checkout.
# Idempotent: safe to re-run; re-running redeploys local changes.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT/.." && pwd)"
CLUSTER=ccc
CTX="kind-$CLUSTER"
SERVICES=(ccc-account-service ccc-web)

for cmd in kind kubectl docker make git; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "error: $cmd is required but not installed" >&2
    exit 1
  }
done

for repo in "${SERVICES[@]}"; do
  if [ ! -d "$REPO_ROOT/$repo" ]; then
    echo "==> cloning missing sibling repo $repo"
    git clone "https://github.com/amcheste/$repo.git" "$REPO_ROOT/$repo"
  fi
done

if ! kind get clusters 2>/dev/null | grep -qx "$CLUSTER"; then
  echo "==> creating kind cluster '$CLUSTER'"
  kind create cluster --name "$CLUSTER" --config "$ROOT/kind-config.yaml"
elif ! kubectl --context "$CTX" get nodes -l ingress-ready=true -o name 2>/dev/null | grep -q .; then
  echo "error: existing '$CLUSTER' cluster was created without ccc-dev's" >&2
  echo "port mappings (probably by a service repo's 'make kind-up')." >&2
  echo "Run 'make down' to delete it, then 'make up' again." >&2
  exit 1
fi

echo "==> installing traefik"
kubectl --context "$CTX" apply -k "$ROOT/manifests/traefik"

echo "==> creating ccc namespace and postgres"
kubectl --context "$CTX" apply -f "$ROOT/manifests/namespace.yaml"
if ! kubectl --context "$CTX" -n ccc get secret postgres-credentials >/dev/null 2>&1; then
  # Local-only throwaway credentials, generated fresh per cluster.
  kubectl --context "$CTX" -n ccc create secret generic postgres-credentials \
    --from-literal=username=ccc \
    --from-literal=password="$(openssl rand -hex 16)"
fi
kubectl --context "$CTX" apply -k "$ROOT/manifests/postgres"

for repo in "${SERVICES[@]}"; do
  echo "==> building and deploying $repo from local checkout"
  make -C "$REPO_ROOT/$repo" kind-deploy TAG=dev
done

echo "==> applying ingress routes"
kubectl --context "$CTX" apply -f "$ROOT/manifests/ingress.yaml"

kubectl --context "$CTX" -n traefik rollout status deploy/traefik --timeout=120s
kubectl --context "$CTX" -n ccc rollout status deploy/postgres --timeout=120s

echo
echo "CCC is up: http://ccc.localhost"
echo "  UI   -> ccc-web (sign-in needs the account service REST API,"
echo "          which lands with its implementation PRs)"
echo "  API  -> http://ccc.localhost/api/account/*"
echo
echo "Roll one service after a code change:  make roll SVC=ccc-web"
echo "Tear down:                             make down"
