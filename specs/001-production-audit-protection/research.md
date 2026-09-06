# Research: Production Audit and Protection

## Existing stack and boundaries

- **Decision**: Retain current dependencies and feature boundaries; add no package.
- **Rationale**: Existing tools support route, persistence, asset, state, and network testing.
- **Alternatives considered**: New analytics/crash/network packages; rejected as excluded scope and added privacy/release risk.

## Compatibility fixtures

- **Decision**: Record routes, arguments, `last_read_index`, asset paths, identity, and signing expectations as explicit test fixtures.
- **Rationale**: They are production interfaces independent of internal code.
- **Alternatives considered**: Manual smoke testing only; rejected because it cannot reliably detect upgrade/data regressions.

## Prayer states

- **Decision**: Distinguish loading, current, stale, offline, invalid, and failed states with location/date provenance.
- **Rationale**: Nullable/hidden failures and fixed fallbacks violate trust and constitution rules.
- **Alternatives considered**: Generic error or fallback time; rejected as misleading or non-diagnostic.

## Religious-content baseline

- **Decision**: Establish approved structural and content fingerprints before UI work.
- **Rationale**: Automated comparison detects encoding, ordering, and text changes missed by visual review.
- **Alternatives considered**: Visual review alone; rejected as insufficient.

## Operational thresholds

- **Decision**: Measure representative baseline performance before setting latency thresholds; enforce zero critical crash/data-loss gates immediately.
- **Rationale**: No trustworthy telemetry or documented threshold exists.
- **Alternatives considered**: Arbitrary numbers; rejected as unevidenced.

## Agent context

- **Decision**: Defer updating staged-deleted `AGENTS.md`.
- **Rationale**: Restoring it would alter user-owned workspace state.
- **Alternatives considered**: Recreate it; rejected without Ahmed's approval.

