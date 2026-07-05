<div align="center">

# ccc-dev

**One command to run the full CCC stack on a local kind cluster.**

[![Validate](https://github.com/amcheste/ccc-dev/actions/workflows/validate.yml/badge.svg)](https://github.com/amcheste/ccc-dev/actions/workflows/validate.yml)
[![Version](https://img.shields.io/github/v/tag/amcheste/ccc-dev?label=version&sort=semver&color=0B0B0C)](https://github.com/amcheste/ccc-dev/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-1F4D3A.svg)](LICENSE)

</div>

---

```sh
make up
```

That clones any missing CCC sibling repos into `~/Repos/amcheste/`,
creates a `ccc` kind cluster with host port mappings, installs
Traefik, deploys a throwaway Postgres, builds every service from your
local checkout (uncommitted changes included), applies the ingress
routes, and finishes with the stack at **http://ccc.localhost**.

| Command | What it does |
|---|---|
| `make up` | full stack from local checkouts; idempotent, re-run to redeploy |
| `make roll SVC=ccc-web` | rebuild one service, roll it onto the cluster |
| `make status` | pods across all namespaces |
| `make down` | delete the cluster |

## How it works

The integration harness deliberately owns **no service config**. Each
service repo carries its own `deploy/kind` overlay and `kind-deploy`
make target; `up.sh` just calls them in order against the shared
`ccc` cluster. What lives here is only the glue no single service
owns: the kind cluster config, Traefik, a local Postgres, and the
ingress that routes one hostname the same way the homelab will
(`/api/account/*` to the API, everything else to the UI, no
rewrites, so auth cookies behave identically).

`ccc.localhost` resolves to 127.0.0.1 in every browser by spec, so
there is no DNS or /etc/hosts setup.

## Deliberate divergences from the homelab

- Postgres is a plain `postgres:17` container with emptyDir storage,
  not the CloudNativePG operator. Credentials are generated per
  cluster at runtime, never committed.
- Plain http on port 80; the homelab terminates TLS.

## UI iteration

For frontend work you usually want hot reload instead of image
rolls: run `make web-dev` in ccc-web (MSW mocks, no cluster needed),
or `VITE_MSW=0 npm run dev` in ccc-web/web to develop against this
stack's real API through the Vite proxy.
