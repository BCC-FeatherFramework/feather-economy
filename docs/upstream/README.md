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
- Upstream `config.lua` should keep only Feather resources active. The fork's
  `framework` branch lists its known consumers (feather-contracts and the bcc
  ports) commented out; `dev-server` is the same file with them active. Those
  consumer lines are server configuration, not part of any proposal.
- Server-console tests take a character UUID (or a server id) and run with
  nobody online. Tests that change data exist only with `Config.DevMode`.
