# orders-api - project memory

A small illustrative service that shows how a **project** consumes the shared
marketplace and layers its own specific, enforcing context on top. This is the
"project level" half of the two-layer split. The plugins in `../claude-plugins/`
are the "plugin level" - the shared spine this project stands on.

## What this project reuses from the marketplace

- **api-guardian** plugin: the `security-auditor` and `api-reviewer` agents, the
  `openapi` and `security` skills. These are generic across every API project,
  so they live in the shared plugin, not here.

This file gives those shared agents the domain context they need to be useful
here - the plugin says "how I review any API", this file says "what THIS API is".

## Domain

orders-api owns the order lifecycle: create, read, cancel. Orders move through
`pending -> confirmed -> shipped -> delivered | cancelled`. An order is immutable
once `shipped`. Money amounts are integer minor units (cents), never floats.

## Conventions specific to this codebase

- **Spec first.** `api/openapi.yaml` is the source of truth. Handlers and models
  are generated from it with `make generate`. Never hand-edit generated code in
  `internal/gen/`; change the spec and regenerate.
- **Errors** use RFC 9457 problem+json. Do not invent ad-hoc error shapes.
- **No secrets in the repo.** Config comes from the environment. `.env` and
  anything under `secrets/` is denied to the agent by `.claude/settings.json`.

## How the six operating principles show up here

Each maps to a real file, so this project is the diagram made literal:

| Principle | Where |
|-----------|-------|
| MCP, sparingly | none here - this service has no heavy data layer, so no project MCP. See "MCP" below. |
| CLIs over integrations | `.claude/settings.json` allow-list is CLIs: `gh`, `git`, `az`, `gcloud`, `make` |
| Allow-list permissions | `.claude/settings.json` (`permissions.allow`) + human-in-loop for the rest |
| docs-as-code | `docs/architecture.md`, kept honest by `.claude/hooks/check-docs-drift.sh` |
| spec-first | `api/openapi.yaml` -> `make generate` -> `internal/gen/` |
| CI/CD SDLC automation | `.github/workflows/ci.yml`, `infra/main.tf`, `policy/ci.rego` |

## MCP

Deliberately none at the project level. An MCP server earns its place on big
multi-service projects with a heavy data layer, where a domain-specific server
is worth the weight. orders-api is a single small service, so a CLI is the
cheaper, composable choice. If this grew into a data platform, a project-scoped
`.mcp.json` would be the place to add one - not the shared plugin.

## Role-based agents

- `orders-backend-engineer` (`.claude/agents/`): scoped to this service. It knows
  the order lifecycle rules above and defers API-review and security work to the
  shared api-guardian agents.
