# Upstream proposals

Additions in this fork of `feather-economy` (0.2.0) relative to
`FeatherFramework/feather-economy` `main`, written as one proposal per pull
request. Open them in this order; each builds only on the ones before it.

| # | Proposal | Migration | Depends on |
|---|---|---|---|
| 1 | [Release gates](01-release-gates.md) | none | none |
| 2 | [Ownership check](02-ownership-check.md) | none | none |
| 3 | [Transaction read](03-transaction-read.md) | none | none |
| 4 | [Bank accounts and registered reasons](04-bank-accounts-and-registered-reasons.md) | 005 | 1 |
| 5 | [Operated treasuries](05-operated-treasuries.md) | 006 | 4 |
| 6 | [History ordering](06-history-ordering.md) | 007 | 4 |

Notes for every proposal:

- Keep the migration ids `005_character_bank_accounts`,
  `006_treasury_operators` and `007_entry_sequence` and their exact
  statements. Servers running this fork have already recorded them with
  their checksums, and a renamed or edited migration would stop their
  startup.
- `config.lua` lists only Feather resources. A server's own consumers go in
  `config_access.lua`, which ships as a template (proposal 1). The fork's
  `framework` branch is this clean state; `dev-server` adds this server's
  consumers to `config_access.lua` only.
- Server-console tests take a character UUID (or a server id) and run with
  nobody online. Tests that change data exist only with `Config.DevMode`.
