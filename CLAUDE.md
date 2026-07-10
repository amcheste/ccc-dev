# CLAUDE.md

This file is read by Claude Code at the start of every session in this repo.

---

## About This Repo

Local integration harness for the Command and Control Center (CCC):
`make up` runs the whole platform (Traefik, Postgres, every service
built from its local sibling checkout under `~/Repos/amcheste/`) on a
kind cluster named `ccc`, served at http://ccc.localhost.

Rules that matter here:

- This repo owns only shared glue: kind config, Traefik, local
  Postgres, ingress routes. Service deploy config stays in each
  service repo's `deploy/kind` overlay; `up.sh` calls their
  `kind-deploy` targets rather than duplicating anything.
- Never commit credentials, even dev ones. The Postgres secret is
  generated at runtime by `scripts/up.sh`.
- The cluster name is `ccc`, shared with the service repos' own
  `make kind-up` targets, but only ccc-dev's kind-config maps host
  port 80. `up.sh` detects a cluster created without the mapping and
  asks for `make down` first.
- Ingress routing must stay rewrite-free and same-origin
  (`/api/<service>` prefixes), mirroring the homelab ingress in
  ccc-deploy; auth cookie behavior depends on it.
- Shell scripts must pass shellcheck; manifests must pass yamllint
  (both enforced by CI).

---

## Developer Preferences

### Editor
- Primary: Vim
- AI editor: Cursor

### Shell
- zsh, minimal prompt

### Git & GitHub Workflow
- **Branch model:** `main` = latest release. `develop` = integration branch.
- Always branch from `develop`, never commit directly
- PRs always target `develop`
- `main` is only updated via CLI merge (`git merge --no-ff origin/develop`) by `/publish-release` — **never via a GitHub PR**. GitHub's merge button squash-merges by default, dropping ancestry and causing conflicts on the next release.
- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`

### Scripting Standards
- Shell scripts must pass `shellcheck`
- Use `set -euo pipefail`
- Scripts should be idempotent

---

## Brand

This repo descends from [`amcheste/repo-template`](https://github.com/amcheste/repo-template), which is brand-aligned with [`@amcheste/brand`](https://github.com/amcheste/alanchester-brand). Badge colors (Hunter Green `#1F4D3A`, Ink `#0B0B0C`) match the brand by default.

When generating prose, follow the brand voice rules at [`voice.md`](https://github.com/amcheste/alanchester-brand/blob/main/docs/voice.md): no em dashes in prose, calibrated hedges over weak ones, lowercase eyebrows, numerical specificity. Hunter green is reserved for data, pivots, and the δ; don't use it as decoration.

For deeper brand integration (palette adoption, mark embedding, full theming sweep), paste [`docs/theming-prompt.md`](https://github.com/amcheste/alanchester-brand/blob/main/docs/theming-prompt.md) from the brand repo into a Claude Code session in this repo.

---

## Learned Preferences

<!-- Claude Code will suggest additions here as patterns emerge across sessions -->
