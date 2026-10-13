# Feather Economy

Authoritative monetary accounting for the Feather Framework.

Shipped defaults use `Config.DevMode=false` and policy-gate currency issuance and
destruction with `Config.Authorization.enabled=true`. Development funding,
concurrency, live transfer, provisioning, and contract-test commands are therefore
not registered. Read-only health/capability exports, foundation/account/journal
audits, and `EconomyReleaseContractSmokeTest` remain available to the server
console. Enable DevMode only on an isolated development server, then disable it
and restart before packaging. Production supply also requires an explicit Core
policy decision; merely being a trusted server resource is insufficient.

Production-surface acceptance passed 7/7 on 2026-09-18: Economy ready, DevMode
disabled, supply policy enabled, development commands absent, journal audit retained,
treasury settlement advertised, and Shops excluded from supply authority. A normal
production-mode shop purchase then succeeded. Closing journal audit passed 5/5,
pending=0, published=78.

The resource provides:

- Feather Contract 1 results, health, capabilities, and readiness;
- checksummed, idempotent database migrations;
- validated `dollars` and `gold` currency definitions;
- immutable persisted currency precision; and
- read-only currency catalog exports;
- atomic character, system, and organization treasury account provisioning; and
- zero-balance account records with trusted server-only reads.

Atomic wallet transfers, balanced journal entries, payload-bound idempotency,
transactional outbox records, and policy-gated currency issuance/destruction
are available.

## Dependencies

```text
oxmysql
feather-core
```

Start Economy after both dependencies:

```text
ensure oxmysql
ensure feather-core
ensure feather-economy
```

## Contract

```lua
local ready = exports['feather-economy']:AwaitReady(30000)
local capabilities = exports['feather-economy']:GetCapabilities()
local currencies = exports['feather-economy']:ListCurrencies()
local dollars = exports['feather-economy']:GetCurrency('dollars')

local wallets = exports['feather-economy']:EnsureCharacterWallets({
    characterId = characterId
})

local paid = exports['feather-economy']:Transfer({
    fromAccountId = buyerWalletId,
    toAccountId = recipientWalletId,
    currency = 'dollars',
    amount = 2500,
    reasonCode = 'shop.purchase',
    referenceType = 'order',
    referenceId = orderId,
    idempotencyKey = requestId
}, context)
```

Account exports are server-only and restricted by `Config.Access`. Consumers
should use the named `GetAccount`, `FindAccountsByOwner`, and
`EnsureCharacterWallets` exports so Cfx can derive the invoking resource.

All operations use Core's flat result envelope:

```lua
{ ok = true, value = value, meta = optionalTable }
{ ok = false, code = 'stable_code', message = 'Safe summary', details = optionalTable }
```

## Validation

From the server console:

```text
EconomyFoundationSmokeTest
```

Expected result: `6/6 passed`.

After the foundation passes:

```text
EconomyAccountContractSmokeTest
EconomyWalletProvisionTest <connected source>
EconomyTransferContractSmokeTest <connected source>
EconomySupplyTest <connected source> <fresh requestId>
EconomyJournalAuditSmokeTest
EconomyTransferLiveTest <sender source> <recipient source> <fresh requestId>
EconomyConcurrencyTest <sender source> <recipient source> <fresh requestId>
```

The account contract is read-only and should pass `7/7`. The wallet test
creates the active character's two zero-balance wallets and verifies that a
retry returns the same account IDs.
The transfer contract test moves no funds and should pass `7/7`.
The supply test issues 100.00 dollars, replays the request, rejects mismatched
payload reuse, verifies balanced entries, and destroys the test amount so the
wallet finishes at its original balance.
The journal audit is read-only. The two-character transfer test funds the
sender, transfers 40.00 dollars with idempotent replay, and destroys the test
funds from both wallets so both finish at their original balances.
The concurrency test injects a rollback after balance writes, then races two
75.00 spends against 100.00. Exactly one may commit; the other must fail for
insufficient funds before both wallets are restored.
# Payment reversal prerequisite

The dev-only server-console funding command also accepts optional currency and
amount: `EconomyShopFundingTest <source> <stable requestId> [dollars|gold]
[minor units 1-10000]`. Defaults remain dollars/200. The existing durable key binds
the wallet, currency, and amount: exact retries replay and changed payloads conflict.
For HUD precision acceptance, use a fresh ID and gold/1, confirm 0.01 on the HUD,
repeat the exact command with no increase, then restart HUD and confirm persistence.
This creates real development funds and does not automatically remove them.

Trusted server callers may use `ReversePayment({ transactionId = originalUuid }, context)`.
Only the caller's own committed `shop.purchase` transfer referencing `shop_order`
is eligible. The original journal supplies the full amount, currency, and reversed
accounts (system sink to buyer wallet). No caller-selected amount, destination,
or request key is accepted. One deterministic reversal key per original payment
prevents duplicate refunds, including after restart. Original entries are checked
under lock; the reversal posts through the existing balanced journal and outbox.
Closed accounts, insufficient sink funds, and wallet limits fail without posting.

This is a trusted server primitive, not a client refund route. Shops must commit
Inventory's cancellation fence before invoking it; Economy does not infer delivery
status. Shops' internal compensation coordinator enforces this fence; no automatic
refund worker or client refund route exists yet.
Shops remains excluded from currency supply privileges.

Run `EconomyPaymentReversalContractSmokeTest` in the server console. Expect 7/7
passes with no funds moved. Live reversal/restart tests follow the shop cancellation
integration; do not reverse an already fulfilled purchase as an acceptance shortcut.
# Organization treasury foundation

`EnsureOrganizationTreasuries({ organizationId = UUID })` is a server-only,
allowlisted provisioning export. It resolves an active canonical identity through
feather-organizations and idempotently provisions one organization-owned treasury
per catalog currency. It cannot seed funds or accept caller-selected account types.
Provisioning authority does not grant player access or ownership-based spending rights.
Organizations is resolved at call time, not an Economy startup dependency.

Migration 004 extends account owner/type constraints without changing previously
applied migration checksums. Existing wallets, journal entries, and system accounts
are retained. Wallet-to-treasury settlement is restricted to `shop.purchase`
transfers with a UUID `shop_order` reference. Normal treasury withdrawals, direct
supply issuance to treasuries, and treasury destruction are not enabled.
`ReversePayment` derives an exact refund from the caller's original committed
payment and verifies its journal entries under lock; it supports treasury and
historical system-sink destinations without accepting caller-selected amounts.

With DevMode enabled, run `EconomyTreasuryContractSmokeTest` (read-only), then
`EconomyTreasuryProvisionTest <active organization UUID>` twice, including after
an Economy restart. Provisioning creates zero-funded accounts, never journal funds.
Identity lookup and local provisioning are not a cross-resource lifecycle lock;
suspension racing a successful lookup may leave a harmless zero-funded treasury.

`EconomyTreasurySettlementContractSmokeTest` checks the isolated account-type
gate without moving funds. End-to-end treasury credit, replay, refund, and restart
recovery are verified using Shops live tests. Provisioning identity does not confer
spending authority; these are trusted server-service operations, not player routes.

Recorded development acceptance: provisioning contract 6/6, two stable treasuries
across server restart, settlement type gate 8/8, live treasury purchase credit=200
exactly once, and undelivered refund restoring 200 with delivery blocked. Latest
journal audit passed 5/5, pending=0, published=60. Treasury purchase/refund recovery
across server restart is still pending; no production-readiness claim is implied.

# Operated accounts (proposed extension, off by default)

This extension is a proposal against master plan §5.2 and §13 (bank accounts,
general treasury spending, payroll and Society management are deferred there).
With the shipped configuration every new access list is empty or holds only
`feather-economy`, `OperatorSupply` is empty, and Economy behaves exactly as
described above: treasuries accept only `shop.purchase` settlement and no resource
can create currency in a bank account.

When a server enables it, an organization treasury can be **bound to one operating
resource**, and only that resource may move it. Economy does not know any
consumer's reason codes: each operator registers its own codes on start and maps
each to one or more fixed **movement shapes**. A movement is allowed only when the
reason is registered by the caller and the accounts match one of its shapes.

| Export | Access group | Effect |
|---|---|---|
| `EnsureCharacterBankAccounts({ characterId, accountRef })` | `trustedBankProvisioners` | One `bank` account per currency for a character, per stable `accountRef` |
| `EnsureOperatedTreasury({ organizationId })` | `trustedTreasuryOperators` | Binds an active organization's treasuries to the caller, permanently (`operator_conflict` if another resource holds it) |
| `RegisterOperatedReasons({ reasons = { [code] = shape or { shapes } } })` | `trustedTreasuryOperators` or `trustedBankTransactors` | Replaces the caller's reason codes. A code belongs to one resource at a time (`reason_conflict`) and is released when that resource stops; `shop.` and `economy.` are reserved |
| `ListAccountEntries({ accountId, limit, offset })` | `trustedReaders` | Journal history: privileged readers any account; others only bank accounts (bank transactors) or a treasury bound to them |

Shapes ("operated" is a treasury bound to the caller; "actor wallet" is the wallet
of `context.actorCharacterId`):

| Shape | From | To | Caller needs |
|---|---|---|---|
| `actor_wallet_to_operated` | actor wallet | operated treasury | `trustedTreasuryOperators` |
| `operated_to_actor_wallet` | operated treasury | actor wallet | `trustedTreasuryOperators` |
| `operated_to_wallet` | operated treasury | any character wallet | `trustedTreasuryOperators` |
| `operated_to_sink` | operated treasury | system sink | `trustedTreasuryOperators` |
| `bank_to_operated` | character bank account | operated treasury | both groups |
| `operated_to_bank` | operated treasury | character bank account | both groups |
| `actor_wallet_to_bank` | actor wallet | character bank account | `trustedBankTransactors` |
| `bank_to_actor_wallet` | character bank account | actor wallet | `trustedBankTransactors` |
| `bank_to_bank` | character bank account | character bank account | `trustedBankTransactors` |
| `bank_to_sink` | character bank account | system sink | `trustedBankTransactors` |
| `issue_to_bank` (supply) | system source | character bank account | `trustedBankTransactors` |
| `issue_to_operated` (supply) | system source | operated treasury | `trustedTreasuryOperators` |

Whether the acting character may act (account access, society rank) stays the
operator's rule; Economy enforces binding, ownership and shape.

Supply stays policy-gated: a supply shape creates currency only while the code is
listed for the caller in `Config.OperatorSupply`, and each issue still needs a Core
policy decision for the caller (`subject.resource`), for example
`Config.servicePolicy['feather-economy']['bcc-banks']['economy.currency.issue']` in
feather-admin. No shape destroys currency.

Example registration (bcc-society):

```lua
exports['feather-economy']:RegisterOperatedReasons({ reasons = {
    ['society.deposit'] = 'actor_wallet_to_operated',
    ['society.bill'] = 'actor_wallet_to_operated',
    ['society.withdraw'] = 'operated_to_actor_wallet',
    ['society.payroll'] = 'operated_to_wallet',
    ['society.tax'] = 'operated_to_sink'
} })
```

Migrations 005 (bank account type and `account_ref`) and 006
(`economy_treasury_operators` binding table) are additive and keep existing rows
unchanged.

Read-only checks: `EconomyBankAccountGateSmokeTest` (test-only operators, no
database writes), `EconomyBankContractSmokeTest`. Named consumers: bcc-banks (bank
accounts, branch reserves) and bcc-society (deposit, withdraw, bills, payroll and
taxes passed live with two players on 2026-10-11).
