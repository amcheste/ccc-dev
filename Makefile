KIND_CLUSTER := ccc
KIND_CONTEXT := kind-$(KIND_CLUSTER)

.PHONY: up roll down status lint

# One command: cluster + traefik + postgres + all services from
# local checkouts, served at http://ccc.localhost
up:
	scripts/up.sh

# Rebuild one service and roll it onto the running cluster:
#   make roll SVC=ccc-web
roll:
	scripts/roll.sh $(SVC)

down:
	kind delete cluster --name $(KIND_CLUSTER)

status:
	kubectl --context $(KIND_CONTEXT) get pods -A

lint:
	shellcheck scripts/*.sh
	yamllint manifests/ kind-config.yaml
