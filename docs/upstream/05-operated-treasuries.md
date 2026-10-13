# 5. Operated treasuries

## What

An organization treasury can be bound, once and permanently, to the one
resource that operates it. That resource may move the treasury only with the
reason codes it registered (proposal 4), using treasury shapes. Every treasury
shape requires the treasury to be bound to the caller:

- `actor_wallet_to_operated` and `operated_to_actor_wallet`;
- `operated_to_wallet` and `operated_to_sink`;
- `bank_to_operated` and `operated_to_bank`;
- `issue_to_operated`.

## Why

The master plan rejects general treasury spending because any trusted
transactor could then drain any treasury. Binding closes that gap. One
resource operates one organization's treasuries, and a shop's or a
government's treasury cannot be moved through another operator's codes.

## Consumer

- A bank resource: each branch has a reserve treasury that funds loans and
  checks.
- A society or business resource: business treasuries that collect payments,
  pay wages and pay tax.

On this server these are `bcc-banks` and `bcc-society`.

## API added

- `EnsureOperatedTreasury({ organizationId })`, gated by
  `trustedTreasuryOperators`:
  - verifies an active organization through `feather-organizations`;
  - binds the treasury on the first call;
  - returns `operator_conflict` when another resource already operates it;
  - provisions the treasuries.
- The treasury shapes above.
- History: an operator may read the treasury bound to it.
- New access group `trustedTreasuryOperators`.
- Capability feature `operatedTreasuries = 1`.

## Migration added

`006_treasury_operators` creates `economy_treasury_operators`:

- `organization_id` (primary key);
- `operator_resource`;
- `created_at`.

## Tests

`EconomyBankAccountGateSmokeTest` covers the treasury cases:

- pay in from the acting character's wallet or a bank account;
- pay out to any wallet or bank account;
- take only into the actor's wallet;
- tax to the sink;
- unbound treasuries and treasuries bound to another operator are rejected;
- supply only into the caller's own treasury.

Live behaviour is covered by the consumer's own tests.
