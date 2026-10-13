# 2. Ownership check

## What

`tools/ownership-check.js` is a dependency-free Node.js script. It scans every
resource, or only those that `server.cfg` starts, for:

- SQL that writes an `economy_*` table (error);
- `UPDATE ... SET` of a money column such as `money`, `gold` or `balance`
  (error);
- VORP or Cfx example currency calls such as `addCurrency`, `removeMoney`
  or `exports.money` (error);
- direct reads of `economy_*` tables (warning, or error with `--strict`).

The exit code is 1 when an error is found. `--allow <resource>` skips a
resource that is being retired.

## Why

Master plan E6 exit: "repository search finds no unauthorized balance
writer". The check makes that search repeatable for every server and every
release, including resources ported from other frameworks.

## Consumer

Server owners, and reviewers of ported resources.

## API added

None. The check is a command-line tool.

## Migration added

None.

## Tests

From the server folder:

```text
node resources/[feather]/feather-economy/tools/ownership-check.js resources --cfg server.cfg
```

Expected: `0 error(s) -> PASS`.
