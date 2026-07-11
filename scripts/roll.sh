#!/usr/bin/env bash
# Rebuild one service from its local checkout and roll it onto the
# running ccc kind cluster. Usage: scripts/roll.sh <repo-name>
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT/.." && pwd)"

SVC="${1:?usage: roll.sh <repo-name, e.g. ccc-web>}"
[ -d "$REPO_ROOT/$SVC" ] || {
  echo "error: $REPO_ROOT/$SVC not found" >&2
  exit 1
}

make -C "$REPO_ROOT/$SVC" kind-deploy TAG=dev
