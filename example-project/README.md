# example-project: orders-api

> [!WARNING]
> **Demo only - not production code.** The service, spec, hooks, IaC, policies,
> and CI here exist to show the *shape* of a well-separated project, not to be
> run in production. Nothing is hardened; the security and deployment steps are
> deliberately simplified. Copy the structure, not the contents.

This is the **project level** of the two-layer split - a small service that
consumes the shared marketplace and layers its own specific, enforcing context
on top. If `claude-plugins/` is the shared spine, this is one project standing
on it.

Read it alongside the parent [README](../README.md): that one shows how to build
and distribute the plugins; this one shows how a real project *uses* them and
adds the six operating principles as runnable files.

## The two levels, made literal

| Level | Lives in | Holds |
|-------|----------|-------|
| Plugin (shared) | `../claude-plugins/api-guardian` | generic agents, skills, commands - true for every API project |
| Project (local) | `example-project/` | this codebase's domain, role agent, enforcement hooks, permissions |

`CLAUDE.md` here gives the shared `api-guardian` agents the domain context they
need. The plugin says "how I review any API"; this project says "what THIS API is".

## The six principles, and the file that proves each

| Principle | File |
|-----------|------|
| **MCP, sparingly** | none - see the "MCP" section in [`CLAUDE.md`](./CLAUDE.md). No heavy data layer, so no project MCP. |
| **CLIs over integrations** | [`.claude/settings.json`](./.claude/settings.json) allow-list is all CLIs: `gh`, `git`, `az`, `gcloud`, `make` |
| **Allow-list, not deny-list** | [`.claude/settings.json`](./.claude/settings.json) `permissions.allow`; anything else asks a human |
| **docs-as-code** | [`docs/architecture.md`](./docs/architecture.md) + [`.claude/hooks/check-docs-drift.sh`](./.claude/hooks/check-docs-drift.sh) |
| **spec-first** | [`api/openapi.yaml`](./api/openapi.yaml) -> `make generate` -> `internal/gen/` |
| **CI/CD SDLC automation** | [`.github/workflows/ci.yml`](./.github/workflows/ci.yml), [`infra/main.tf`](./infra/main.tf), [`policy/ci.rego`](./policy/ci.rego) |

## Layout

```
example-project/
├── CLAUDE.md                         # project memory: domain, conventions, principle map
├── .claude/
│   ├── settings.json                 # allow-list permissions + hook wiring (committed)
│   ├── settings.local.json.example   # personal overrides (gitignored in real use)
│   ├── agents/
│   │   └── orders-backend-engineer.md  # role-based, project-scoped agent
│   ├── skills/
│   │   └── orders-domain/SKILL.md     # project-knowledge skill
│   └── hooks/
│       ├── hooks.json                 # reference copy of the wiring
│       ├── guard-destructive.sh       # PreToolUse: block irreversible commands, audit log
│       └── check-docs-drift.sh        # PostToolUse: fail if the contract outran the docs
├── api/
│   ├── openapi.yaml                  # the contract - source of truth
│   ├── codegen.yaml                  # oapi-codegen config
│   └── ...
├── internal/gen/                     # generated models (never hand-edited)
├── docs/architecture.md              # docs-as-code, watched by the drift hook
├── infra/main.tf                     # declarative IaC (validated in CI, never applied from CI)
├── policy/ci.rego                    # policy-as-code, enforced with conftest
├── Makefile                          # make generate | verify | sbom
└── .github/workflows/ci.yml          # quality gates -> policy -> security (OWASP+SBOM) -> IaC -> GitOps
```

## Try it

```bash
# From the repo root, load the shared plugin and open this project.
cd example-project
claude --plugin-dir ../claude-plugins/api-guardian

# Ask the project agent to add a field - it will change the spec, not the models.
# Watch the docs-drift hook fire if you skip updating docs/architecture.md.
```

> Everything here is illustrative - it shows the structure and the wiring, not
> production tooling. The point is the shape: a shared spine, a local enforcing
> layer, and six principles you can point at.
