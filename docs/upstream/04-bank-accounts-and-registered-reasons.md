# 4. Bank accounts and registered reasons

## What

- Character bank accounts: `account_type = 'bank'`, identified by a
  caller-chosen `account_ref`, so a character can hold several accounts in
  one currency (for example one per branch).
- Operator-registered reason codes. Economy knows a closed set of movement
  shapes (`server/services/operators.lua`). An operator registers its own
  reason codes on every start and maps each code to shapes. A posting with a
  registered code is allowed only when its accounts match one of the code's
  shapes. Bank shapes:
  - `actor_wallet_to_bank` and `bank_to_actor_wallet`;
  - `bank_to_bank` and `bank_to_sink`;
  - `issue_to_bank`.
- Account history: `ListAccountEntries({ accountId, limit, offset })`,
  newest first, with the counterparty account on each entry.
- `Config.OperatorSupply[resource][reasonCode]`: an exact list of the
  reason codes a resource may create currency with. These still need the
  Core policy grant.

## Why

The master plan defers banks until a named consumer exists. A bank resource
is that consumer. Without bank accounts it would keep balances in its own
tables, which E6 forbids.

Economy should not hardcode `bank.*` codes. It owns the safety rules (which
account types may move, whose wallet, and who may create currency), while the
consumer owns its business vocabulary. Codes starting with `shop.` and
`economy.` are reserved.

## Consumer

A bank resource (`bcc-banks` on this server): deposits, withdrawals,
transfers, fees, statements, and a one-time import of balances from its old
tables.

## API added

- `EnsureCharacterBankAccounts({ characterId, accountRef })`, gated by
  `trustedBankProvisioners`.
- `RegisterOperatedReasons({ reasons = { [code] = shape | { shapes } } })`,
  gated by `trustedBankTransactors`. Codes are released when the resource
  stops.
- `ListAccountEntries({ accountId, limit, offset })`, gated by
  `trustedReaders`:
  - privileged readers may read any account;
  - bank transactors may read bank accounts;
  - unknown and foreign accounts both return `authorization_denied`.
- New access groups: `trustedBankProvisioners`, `trustedBankTransactors`
  and `privilegedHistoryReaders` (from proposal 3).
- `Config.OperatorSupply`.
- Capability features `bankAccounts = 1` and `accountHistory = 1`.
- `EconomyJournal.AccountTypesAllowed` receives the resource, the context and
  the transaction connection. The v1 rules are unchanged.

## Migration added

`005_character_bank_accounts`, a single atomic `ALTER TABLE`:

- adds `account_ref`, which is `''` for existing rows;
- widens the owner/type constraints to allow `bank`;
- makes `(owner_type, owner_id, account_type, currency_code, account_ref)`
  the unique key.

Existing wallets, treasuries and system accounts are unchanged.

## Tests

- `EconomyBankAccountGateSmokeTest`: registration, conflicts, reserved
  prefixes, every bank shape, the actor-wallet rule, joint holders, supply
  listing, and released codes. It uses in-memory test operators and moves no
  funds.
- `EconomyBankContractSmokeTest`: provisioning input validation, history
  access and limits, and account-type integrity. Read-only.
- `EconomyBankLiveTest <character> <requestId>` (DevMode): deposit, replay,
  overdraw, withdrawal, fee and history, using the character's own wallet.
