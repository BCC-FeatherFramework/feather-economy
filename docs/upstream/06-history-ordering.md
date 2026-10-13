# 6. History ordering

## What

Migration 007 adds an `AUTO_INCREMENT` `entry_sequence` to `economy_entries`.
`ListAccountEntries` orders by `posted_at DESC, entry_sequence DESC` and
returns each entry's `sequence`.

## Why

Posting timestamps have one-second precision. History used `entry_id`
ascending as the tie-breaker, and MySQL `UUID()` values sort roughly in time
order within a second. So entries posted in the same second came out oldest
first. A real statement listed a fee before the withdrawal that followed it,
and that withdrawal's resulting balance did not chain.

Balance rows are locked while posting, so one account's sequence numbers are
in posting order. Existing rows are numbered in `entry_id` order, which matches
posting order within a second. On the development data the balance chain held
for every account under that order before the migration.

## Consumer

Any history reader. A bank statement is the first one (proposal 4).

## API added

`sequence` on each `ListAccountEntries` entry. Offset paging shifts when
entries are posted between page reads; a consumer can drop repeated sequences.

## Migration added

`007_entry_sequence`, a single `ALTER TABLE` that:

- adds `entry_sequence BIGINT UNSIGNED NOT NULL AUTO_INCREMENT`;
- adds a unique key on it;
- adds an `(account_id, entry_sequence)` index.

It rebuilds `economy_entries`.

## Tests

- `EconomyReleaseGateSmokeTest` (read-only):
  - bad limits and offsets are rejected;
  - pages of three match one page;
  - the newest entry equals the balance;
  - an offset past the end returns nothing;
  - "history order matches balances" across every account.
- `EconomyHistoryPaginationTest <character> <requestId>` (DevMode): posts
  seven entries quickly, then checks newest-first order, paging, no repeats,
  descending sequence, the balance chain, limits and offsets, and that the
  test funds were removed.
