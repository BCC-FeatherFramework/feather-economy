# Proposed master plan update

Proposed edits to `feather-economy/Feather_Economy_Master_Plan.md` in
`FeatherFramework/feather-framework-docs`, to be applied by hand. Section
numbers refer to the plan as of its 2026-09-18 checkpoint.

## Header

- **Last revised:** 2026-10-13
- **Status:** Contract 1 implemented through E6. Release gates passed on the
  development server and again in the production profile on 2026-10-13.

## Section 2.1, Admin row

| Admin | `/givemoney` and `/takemoney` call `Issue`/`Destroy` with Admin's service grants (`economy.currency.issue`/`destroy`) after an owner capability check; wallets come from `EnsureCharacterWallets` and are read with `GetAccount` | Offline targeting, staff actor identity in the journal and Admin Economy screens remain |

## Section 5.2, owners and accounts

Add the account type `bank`: character-owned, one per currency for each
caller-chosen `account_ref`.

Add operated treasuries: an organization treasury that is bound once to one
operator resource (`EnsureOperatedTreasury`). Only that operator may move it,
and only with reason codes it registered (`RegisterOperatedReasons`). Economy
knows a closed set of movement shapes. Operators bring their own codes; the
`shop.` and `economy.` prefixes are reserved.

## Section 6, persistence

- `economy_accounts`: add `account_ref`. Uniqueness becomes
  `(owner_type, owner_id, account_type, currency_code, account_ref)`.
- `economy_entries`: add `entry_sequence`, which orders history by posting.
- New table `economy_treasury_operators (organization_id, operator_resource,
  created_at)`.
- Migrations 001 to 007. Every recorded checksum is verified before anything
  runs. A migration is one statement, or only `CREATE TABLE IF NOT EXISTS`
  statements. A failed migration drops what it created and reports the
  migration, the statement and the reason.

## Section 7, public Contract 1

Move `GetTransaction` from planned to implemented. Add these exports:

- `GetTransaction({ transactionId })`: posted by the caller, or read by a
  privileged history reader.
- `ListAccountEntries({ accountId, limit, offset })`: newest first, with
  `sequence`.
- `EnsureCharacterBankAccounts({ characterId, accountRef })`.
- `EnsureOperatedTreasury({ organizationId })`.
- `RegisterOperatedReasons({ reasons })`.

`GetBalance`, `ListTransactions` and `CloseAccount` remain planned.

Supply denials carry `details.policyCode`. An error raised by the Core call
also denies.

## Section 11, E6

Mark the ownership check as done: `tools/ownership-check.js`, 0 errors over
the started resources. The only warning is a direct read of
`economy_transactions` in a `feather-contracts` test, which should move to
`GetTransaction`.

Mark the Admin integration review as done. The money commands use Economy
exports and service grants only. Follow-ups are listed under section 14.

## Section 12, acceptance gates

Add the test that covers each gate:

| Gate | Test | Status |
|---|---|---|
| Clean install, rerun, checksum mismatch, migration failure | `EconomyReleaseGateSmokeTest`, `EconomyMigrationFaultTest`, the `economy_dev_migration_fault` startup switch | passed (23/23, 8/8, startup failed closed) |
| Integer minor units; balanced transactions | `EconomyJournalAuditSmokeTest`; "balances equal their entries" | passed 5/5 |
| Concurrent spending; failure injection | `EconomyConcurrencyTest` | passed |
| Exact retry; mismatched payload | `EconomySupplyTest`, `EconomyRestartTest` | passed, also after restart |
| Restart preserves balances, journal, outbox, replay | `EconomyRestartTest prepare/verify` | passed 10/10 |
| Unauthorized supply and policy-provider failure | `EconomyReleaseGateSmokeTest` (missing, denying, failing, invalid provider; untrusted supplier; Core) | passed |
| Bounded reads; history paging and ordering | `EconomyReleaseGateSmokeTest`, `EconomyHistoryPaginationTest`, `EconomyBankContractSmokeTest` | passed (bank contract 14/14) |
| No first-party writer of Economy tables | `tools/ownership-check.js` | passed |
| Shops payment, fulfillment, restart, reconciliation | Shops live tests | passed |

## Section 13, deferred work

Bank accounts and operated treasury spending are no longer deferred: they are
implemented as operated accounts, with a bank resource and a society resource
as the named consumers. Loans, checks, fees and exchange remain the bank
resource's business logic, built on these shapes.

## Section 14, remaining work

1. Admin: accept a character UUID for offline wallet corrections. Record the
   staff character, not the target, as `actorCharacterId`. Remove or wire the
   legacy client Economy screens. Add Economy grants to Admin's release smoke
   test.
2. Validate clean recipe deployment with merged upstream resources.
3. Upstream the fork's additions in the order given in
   `feather-economy/docs/upstream/`.
4. `feather-contracts`: replace its test's direct read of
   `economy_transactions` with `GetTransaction`.

## New checkpoint

### Release candidate checkpoint, 2026-10-13

History ordering was wrong for entries posted in the same second (oldest
first). Migration 007 adds a posting sequence, and history now orders by it.
The migration runner verifies all checksums before running anything and
leaves nothing half applied. Supply denies when the Core policy call raises.

Release gate tests were added for migrations, paging, restart and policy
failure. All console tests take character UUIDs and run with nobody online.
DevMode is off and supply policy is on. On the development server the release
gate passed 23/23, migration faults 8/8, pagination 10/10 and restart 10/10
across a full server restart; a failing migration stopped startup with an
actionable error and kept nothing. With DevMode off, every read-only test
passed (release contract 7/7, release gate 23/23, foundation 6/6, account
contract 7/7, bank contract 14/14, transaction read 9/9, journal audit 5/5),
and the ownership check found 0 errors.
