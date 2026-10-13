-- This server's own Economy consumers. config.lua lists only Feather resources;
-- add every other resource that calls Economy here, then restart feather-economy.
-- A resource cannot add itself: only this file and config.lua decide who is
-- trusted. See README "Access groups" for what each group allows.

local function Trust(resource, groups)
    for _, group in ipairs(groups) do
        assert(type(Config.Access[group]) == 'table',
            ('config_access.lua: unknown access group %s'):format(tostring(group)))
        Config.Access[group][resource] = true
    end
end

-- Examples:
--
-- A store that charges players into the system sink:
-- Trust('my-store', { 'trustedReaders', 'trustedProvisioners', 'trustedTransactors' })
--
-- A bank with character bank accounts and branch reserve treasuries, which may
-- create currency only for a one-time balance import (also needs the
-- economy.currency.issue grant in the policy provider):
-- Trust('my-bank', { 'trustedReaders', 'trustedProvisioners', 'trustedTransactors',
--     'trustedBankProvisioners', 'trustedBankTransactors', 'trustedTreasuryOperators' })
-- Config.OperatorSupply['my-bank'] = { ['bank.migration.import'] = true }

-- This server -------------------------------------------------------------

-- Reconciles and settles obligations such as rent and tax (GetTransaction, Transfer).
Trust('feather-contracts', { 'trustedReaders', 'trustedTransactors' })

-- Store purchases paid into the system sink.
Trust('bcc-shops', { 'trustedReaders', 'trustedProvisioners', 'trustedTransactors' })

-- Crafting book purchases paid into the system sink.
Trust('bcc-craft', { 'trustedReaders', 'trustedProvisioners', 'trustedTransactors' })

-- Horse, tack and taming purchases paid into the system sink. Horse sales to the
-- stable pay out with Issue and are refused until bcc-stables is also a
-- trustedSupplier with the economy.currency.issue grant.
Trust('bcc-stables', { 'trustedReaders', 'trustedProvisioners', 'trustedTransactors' })

-- House purchases, rent and tax. Sale back to the housing agent and furniture
-- sell-back create money (also needs the economy.currency.issue grant).
Trust('bcc-housing', { 'trustedReaders', 'trustedProvisioners', 'trustedTransactors',
    'trustedSuppliers' })

-- Business treasuries: deposits, withdrawals, payroll, bills and tax, with the
-- society.* reasons it registers.
Trust('bcc-society', { 'trustedReaders', 'trustedProvisioners', 'trustedTransactors',
    'trustedTreasuryOperators' })

-- Bank accounts (one per character and branch), statements and branch reserve
-- treasuries, with the bank.* reasons it registers. Loans, checks, box fees and
-- gold exchange settle against the branch reserve; only the one-time balance
-- import and funding a reserve create currency (also needs the
-- economy.currency.issue grant).
Trust('bcc-banks', { 'trustedReaders', 'trustedProvisioners', 'trustedTransactors',
    'trustedBankProvisioners', 'trustedBankTransactors', 'trustedTreasuryOperators' })
Config.OperatorSupply['bcc-banks'] = {
    ['bank.migration.import'] = true,
    ['bank.reserve.funding'] = true
}
