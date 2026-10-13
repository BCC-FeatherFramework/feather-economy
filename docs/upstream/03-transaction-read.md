# 3. Transaction read

## What

`GetTransaction({ transactionId })` returns one journal transaction:

- `operation`, `status` and `currency`;
- `amount`, the total moved;
- `reasonCode`, `referenceType` and `referenceId`;
- `sourceResource`, `correlationId`, `createdAt` and `postedAt`;
- `entries`, each with `accountId` and a signed `amount`.

## Why

A service that settles obligations through Economy stores the transaction id.
After a timeout or a restart it must confirm what was posted, without reading
Economy tables. The master plan lists `GetTransaction` as planned.

## Consumer

A contracts or settlement resource that reconciles its pending settlements
against the journal (`feather-contracts` on this server).

## API added

- Export `GetTransaction({ transactionId })`, gated by `trustedReaders`.
- A caller reads only transactions it posted, unless it is in the new
  `privilegedHistoryReaders` group.
- Unknown and foreign transactions both return `transaction_not_found`.
- Capability feature `transactionRead = 1`.

## Migration added

None.

## Tests

`EconomyTransactionReadSmokeTest` (read-only): capability, untrusted reader,
malformed id, unknown field, unknown transaction, the poster reading its own
transaction, balanced entries, a foreign reader hidden, and the privileged
reader.

`privilegedHistoryReaders` is introduced here. Proposal 4 uses it for account
history as well.
