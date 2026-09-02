---
name: orders-domain
description: Project-knowledge skill for orders-api. The order lifecycle, invariants, and money handling specific to this codebase. Loads when working on order logic in this service.
user-invocable: false
allowed-tools: Read, Grep, Glob
---

# orders-domain

Project-specific knowledge. This is the kind of skill that belongs at the
**project level**, not in the shared marketplace: it is true for this codebase
and nowhere else. A generic "REST best practices" skill would live in a plugin;
this one would be noise everywhere but here.

## Order lifecycle

```
pending -> confirmed -> shipped -> delivered
   |            |
   +------------+--> cancelled
```

- `pending`: created, not yet paid. Cancellable.
- `confirmed`: payment captured. Cancellable until shipped.
- `shipped`: handed to carrier. **Immutable.** No cancel, no edit.
- `delivered`: terminal, success.
- `cancelled`: terminal, before shipment only.

## Invariants

- An order is immutable once `shipped`. Any transition out of `shipped` other
  than `delivered` is a bug.
- Amounts are integer minor units (cents). Never floats.
- Every state change appends an audit entry. History is never mutated in place.

## Errors

RFC 9457 problem+json only. `type`, `title`, `status`, `detail`, `instance`.
No ad-hoc error shapes.
