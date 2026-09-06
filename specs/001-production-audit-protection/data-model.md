# Data Model: Production Audit and Protection

## Production Baseline

- App identity and version/signing expectations
- Supported platforms and representative devices
- Routes and argument contracts
- Persisted keys, types, ranges, and compatibility status
- Asset inventory and integrity identifiers
- Network dependencies and failure/provenance behavior
- Working-tree state and ownership disposition
- Verification evidence

## Compatibility Contract

- `kind`: route, argument, persisted key, asset path, identity, or signing
- `identifier`: canonical path/key/name
- `valueRules`: accepted shape or range
- `migrationRequired`: whether compatibility needs migration
- `rollbackPlan`: mandatory for migration

Known contract: `last_read_index` preserves readable Quran progress. Missing or invalid values recover without destructive overwrite.

## Religious Content Baseline

- Asset path and content type
- Verified source attribution and reviewer
- Required structure, ordering, and relationships
- Comparison fingerprint
- Explicitly approved differences

## Prayer Data Freshness Descriptor

- Location and represented date
- Retrieval time when known
- State: loading, current, stale, offline, invalid, or failed
- Validated prayer values where applicable
- Typed failure and recovery action

## Audit Finding

- Stable ID, severity, current evidence, affected scope, risk
- Required acceptance evidence and disposition
- Release-blocking status and rollback relevance

## Release Evidence Record

- Candidate/environment
- Upgrade, automated, manual, and integrity results
- Known risks and owner decisions
- Rollout decision and rollback trigger

