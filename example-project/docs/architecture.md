# orders-api architecture

> docs-as-code: this document lives in the repo next to the code and is kept
> honest by `.claude/hooks/check-docs-drift.sh`. Change the API contract without
> updating this file in the same change, and the hook fails the run.

## Shape

A single Go service. HTTP handlers are generated from `api/openapi.yaml`
(spec-first) and wired to a small domain core that enforces the order lifecycle.

```
request -> generated chi server (internal/gen) -> domain core -> store
```

## Order lifecycle

`pending -> confirmed -> shipped -> delivered | cancelled`. An order is immutable
once shipped. See `.claude/skills/orders-domain/SKILL.md` for the full rules -
kept in one place so the doc and the agent's knowledge cannot diverge.

## Boundaries

- The contract (`api/openapi.yaml`) is the only public surface.
- Config comes from the environment. No secrets in the repo.
- Cross-cutting API review and security are handled by the shared api-guardian
  plugin, not re-implemented here.
