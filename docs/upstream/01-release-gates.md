# 1. Release gates

## What

Closes the master plan section 12 gates that had no test: migration rerun,
checksum mismatch and failure; supply policy failure; restart recovery.

- Migration runner (`server/persistence/migrations.lua`):
  - Compares every recorded checksum before running anything.
  - Accepts only migrations that cannot be left half applied: one statement,
    or only `CREATE TABLE IF NOT EXISTS economy_*` statements.
  - When a statement or the ledger insert fails, drops the tables that run
    created. The error names the migration, the statement, the driver reason
    and the next step.
  - Logs recorded ids it does not know instead of ignoring them.
  - `Run(definitions)` accepts a list, for tests.
- Supply gate (`EconomyAPI.Supply`): an error raised by the Core `Authorize`
  call now denies like every other failure. Denials carry `details.action`
  and `details.policyCode`.
- Console tests:
  - `EconomyHealthReport` and `EconomyReleaseGateSmokeTest` (read-only).
  - `EconomyMigrationFaultTest` and `EconomyRestartTest` (DevMode).
  - The `economy_dev_migration_fault` startup switch (DevMode).
  - Every development test takes a character UUID or a server id
    (`server/test_support.lua`) and posts test funds through the journal.
- `config_access.lua`: a server's own consumers, added with
  `Trust(resource, groups)` after `config.lua`, so `config.lua` keeps only
  Feather resources and upgrades never touch a server's trust entries.
- `EconomyAccountContractSmokeTest` checks the signs of the system balances
  instead of requiring zero. The old check failed after the first supply.

## Why

The master plan lists clean install, rerun, checksum mismatch, migration
failure, restart preservation and policy-provider failure as release gates,
and records them as untested. The old runner applied pending migrations
before it noticed a later checksum mismatch. A failed multi-statement
migration kept its earlier tables. A Core error during supply escaped to the
caller. Development tests needed connected players, and issued through the
policy gate, which no server grants Economy itself.

## Consumer

Server owners and release packaging. Every consumer benefits from a supply
gate that denies on error.

## API added

`EconomyAPI.Supply(operation, request, context, resource, authorize)` is
internal and not exported. Exports are unchanged. Supply denials add
`details.policyCode`.

## Migration added

None.

## Tests

- `EconomyReleaseGateSmokeTest`, read-only (in the fork, 23 checks). For this
  pull request, leave out the history paging and ordering checks: they need
  proposals 4 and 6.
- `EconomyMigrationFaultTest` (8 checks).
- `EconomyRestartTest prepare|verify` across a full restart (10 checks).
- The startup switch: `set economy_dev_migration_fault failure|checksum|invalid`,
  `restart feather-economy`, then `EconomyHealthReport` shows `state=failed`
  with the code and migration id.
