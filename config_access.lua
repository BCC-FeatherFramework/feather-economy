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
