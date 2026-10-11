-- The gate and contract tests are read-only and stay available in the production
-- profile; only the live movement test needs Config.DevMode.

local function Counter(name)
    local passed, total = 0, 0
    return function(label, condition)
        total = total + 1
        if condition then passed = passed + 1 end
        print(('[%s] %s %s'):format(name, label, condition and 'PASS' or 'FAIL'))
    end, function() return passed, total end
end

RegisterCommand('EconomyBankAccountGateSmokeTest', function(source)
    if source ~= 0 then return end
    local Check, Result = Counter('EconomyBankAccountGateSmokeTest')
    local owner = '11111111-1111-1111-1111-111111111111'
    local other = '22222222-2222-2222-2222-222222222222'
    local wallet = { account_type = 'wallet', owner_type = 'character', owner_id = owner }
    local bank = { account_type = 'bank', owner_type = 'character', owner_id = owner }
    local otherWallet = { account_type = 'wallet', owner_type = 'character', owner_id = other }
    local otherBank = { account_type = 'bank', owner_type = 'character', owner_id = other }
    local sink = { account_type = 'system_sink', owner_type = 'system' }
    local treasury = { account_type = 'treasury', owner_type = 'organization', owner_id = owner }
    local allowed = EconomyJournal.AccountTypesAllowed
    local banker = 'bcc-banks'
    local asOwner, asOther = { actorCharacterId = owner }, { actorCharacterId = other }

    Check('deposit own wallet to own bank', allowed('transfer', wallet, bank, { reasonCode = 'bank.deposit' }, banker, asOwner) == true)
    Check('withdraw own bank to own wallet', allowed('transfer', bank, wallet, { reasonCode = 'bank.withdraw' }, banker, asOwner) == true)
    Check('bank to another bank transfer', allowed('transfer', bank, otherBank, { reasonCode = 'bank.transfer' }, banker) == true)
    Check('bank fee to system sink', allowed('transfer', bank, sink, { reasonCode = 'bank.fee' }, banker) == true)

    Check('deposit without actor uses same-owner rule', allowed('transfer', wallet, bank, { reasonCode = 'bank.deposit' }, banker) == true)
    Check('joint holder deposits from own wallet', allowed('transfer', otherWallet, bank, { reasonCode = 'bank.deposit' }, banker, asOther) == true)
    Check('joint holder withdraws to own wallet', allowed('transfer', bank, otherWallet, { reasonCode = 'bank.withdraw' }, banker, asOther) == true)
    Check('joint deposit from another wallet rejected', not allowed('transfer', otherWallet, bank, { reasonCode = 'bank.deposit' }, banker, asOwner))
    Check('joint withdraw to another wallet rejected', not allowed('transfer', bank, otherWallet, { reasonCode = 'bank.withdraw' }, banker, asOwner))
    Check('joint without actor rejected', not allowed('transfer', otherWallet, bank, { reasonCode = 'bank.deposit' }, banker))
    Check('untrusted caller rejected', not allowed('transfer', wallet, bank, { reasonCode = 'bank.deposit' }, 'feather-shops'))
    Check('missing caller rejected', not allowed('transfer', wallet, bank, { reasonCode = 'bank.deposit' }))
    Check('deposit with mismatched actor rejected', not allowed('transfer', wallet, otherBank, { reasonCode = 'bank.deposit' }, banker, asOther))
    Check('withdraw with mismatched actor rejected', not allowed('transfer', bank, otherWallet, { reasonCode = 'bank.withdraw' }, banker, asOwner))
    Check('wallet to bank needs bank reason', not allowed('transfer', wallet, bank, { reasonCode = 'shop.purchase' }, banker))
    Check('bank to wallet needs bank reason', not allowed('transfer', bank, wallet, {}, banker))
    Check('wallet cannot use withdraw reason', not allowed('transfer', wallet, bank, { reasonCode = 'bank.withdraw' }, banker))
    Check('bank cannot be shop-settled', not allowed('transfer', bank, treasury, { reasonCode = 'bank.transfer' }, banker))
    Check('bank to wallet of another owner via transfer rejected', not allowed('transfer', bank, otherWallet, { reasonCode = 'bank.transfer' }, banker))
    Check('fee cannot target a wallet', not allowed('transfer', bank, wallet, { reasonCode = 'bank.fee' }, banker))
    Check('bank cannot be issued to', not allowed('issue', { account_type = 'system_source', owner_type = 'system' }, bank, { reasonCode = 'bank.deposit' }, banker))
    Check('bank cannot be destroyed from', not allowed('destroy', bank, sink, { reasonCode = 'bank.fee' }, banker))
    Check('bank cannot be reversal target', not allowed('reversal', sink, bank, { reasonCode = 'bank.deposit' }, banker))
    local source = { account_type = 'system_source', owner_type = 'system' }
    Check('allow-listed issue to bank', allowed('issue', source, bank, { reasonCode = 'bank.migration.import' }, banker) == true)
    Check('loan supply retired', not allowed('issue', source, bank, { reasonCode = 'bank.loan.disbursement' }, banker))
    Check('repayment destroy retired', not allowed('destroy', bank, sink, { reasonCode = 'bank.loan.repayment' }, banker))
    Check('unlisted reason cannot issue to bank', not allowed('issue', source, bank, { reasonCode = 'bank.anything' }, banker))
    Check('other caller cannot issue to bank', not allowed('issue', source, bank, { reasonCode = 'bank.migration.import' }, 'bcc-shops'))
    Check('unbound treasury is not a reserve', not allowed('transfer', treasury, bank, { reasonCode = 'bank.loan.disbursement' }, banker))
    Check('unbound treasury cannot take repayment', not allowed('transfer', bank, treasury, { reasonCode = 'bank.loan.repayment' }, banker))
    Check('unbound treasury cannot be funded', not allowed('issue', source, treasury, { reasonCode = 'bank.reserve.funding' }, banker))
    Check('bank supply lookup', EconomyJournal.BankSupplyAllowed(banker, 'bank.reserve.funding') == true
        and EconomyJournal.BankSupplyAllowed(banker, 'bank.check.cash') == false
        and EconomyJournal.BankSupplyAllowed(nil, nil) == false)
    Check('existing wallet transfer unchanged', allowed('transfer', wallet, otherWallet, {}, banker) == true)
    local passed, total = Result()
    print(('[EconomyBankAccountGateSmokeTest] done %d/%d passed (isolated account-type gate; no funds moved)'):format(passed, total))
end, true)

RegisterCommand('EconomyBankContractSmokeTest', function(source)
    if source ~= 0 then return end
    local Check, Result = Counter('EconomyBankContractSmokeTest')
    local features = EconomyAPI.GetCapabilities().value.features
    Check('bank capabilities', features.bankAccounts == 1 and features.accountHistory == 1)
    local denied = EconomyAPI.EnsureCharacterBankAccounts({ characterId = Config.SystemOwnerId }, 'untrusted-resource')
    Check('untrusted provision rejected', not denied.ok and denied.code == 'authorization_denied')
    local invalid = EconomyAPI.EnsureCharacterBankAccounts({}, 'feather-economy')
    Check('missing identity rejected', not invalid.ok and invalid.code == 'invalid_input')
    invalid = EconomyAPI.EnsureCharacterBankAccounts({ characterId = Config.SystemOwnerId }, 'feather-economy')
    Check('missing account reference rejected', not invalid.ok and invalid.code == 'invalid_input')
    invalid = EconomyAPI.EnsureCharacterBankAccounts({ characterId = Config.SystemOwnerId, accountRef = 'bad ref!' }, 'feather-economy')
    Check('malformed account reference rejected', not invalid.ok and invalid.code == 'invalid_input')
    invalid = EconomyAPI.EnsureCharacterBankAccounts({ characterId = 'bad', accountRef = 'a' }, 'feather-economy')
    Check('malformed UUID rejected', not invalid.ok and invalid.code == 'invalid_input')
    invalid = EconomyAPI.EnsureCharacterBankAccounts({ characterId = Config.SystemOwnerId, balance = 100 }, 'feather-economy')
    Check('balance injection rejected', not invalid.ok and invalid.code == 'invalid_input')
    invalid = EconomyAPI.EnsureCharacterBankAccounts({ characterId = Config.SystemOwnerId, accountType = 'wallet' }, 'feather-economy')
    Check('account type injection rejected', not invalid.ok and invalid.code == 'invalid_input')
    local unreadable = EconomyAPI.ListAccountEntries({ accountId = Config.SystemOwnerId }, 'untrusted-resource')
    Check('untrusted history rejected', not unreadable.ok and unreadable.code == 'authorization_denied')
    local foreign = EconomyAPI.ListAccountEntries({ accountId = Config.SystemOwnerId }, 'feather-hud')
    Check('foreign history rejected', not foreign.ok and foreign.code == 'authorization_denied')
    local malformed = EconomyAPI.ListAccountEntries({ accountId = 'bad' }, 'feather-economy')
    Check('history malformed account rejected', not malformed.ok and malformed.code == 'invalid_input')
    local oversized = EconomyAPI.ListAccountEntries({ accountId = Config.SystemOwnerId,
        limit = Config.Limits.maximumPageSize + 1 }, 'feather-economy')
    Check('history oversized page rejected', not oversized.ok and oversized.code == 'invalid_input')
    local rows = DB.query([[SELECT `account_id` FROM `economy_accounts`
        WHERE (`account_type`='bank' AND (`owner_type`<>'character' OR `account_ref`=''))
           OR (`account_type`<>'bank' AND `account_ref`<>'')
           OR (`owner_type`='character' AND `account_type` NOT IN ('wallet','bank'))]]) or {}
    Check('bank owner type integrity', #rows == 0)
    local constraint = DB.value([[SELECT COUNT(*) FROM `economy_schema_migrations`
        WHERE `id`='005_character_bank_accounts']])
    Check('bank migration applied', tonumber(constraint) == 1)
    local passed, total = Result()
    print(('[EconomyBankContractSmokeTest] done %d/%d passed (no accounts created or funds moved)'):format(passed, total))
end, true)

if not Config.DevMode then return end

-- Live movement test. Usage: EconomyBankLiveTest <connected source> <fresh requestId>
-- Funds the character's wallet through the supply primitive, deposits, withdraws
-- and charges a fee, replays each call, rejects an overdraw, checks the history,
-- then returns the funds so the character's wallet and bank finish at their
-- original balances. The system source/sink accounts keep the net supply record.
RegisterCommand('EconomyBankLiveTest', function(source, args)
    if source ~= 0 then return end
    local called, failure = xpcall(function()
        local serverId, requestId = tonumber(args[1]), args[2]
        assert(serverId and type(requestId) == 'string' and requestId ~= '', 'usage: EconomyBankLiveTest <source> <requestId>')
        local session = exports['feather-core']:GetSessionContext(serverId)
        assert(type(session) == 'table' and session.ok and session.value and session.value.characterId, 'character session unavailable')
        local characterId = session.value.characterId:lower()
        local wallets = EconomyAPI.EnsureCharacterWallets({ characterId = characterId }, 'feather-economy')
        local banks = EconomyAPI.EnsureCharacterBankAccounts({ characterId = characterId, accountRef = 'live-test-1' }, 'feather-economy')
        local second = EconomyAPI.EnsureCharacterBankAccounts({ characterId = characterId, accountRef = 'live-test-2' }, 'feather-economy')
        assert(wallets.ok and banks.ok and second.ok, 'provisioning failed')
        local replayBanks = EconomyAPI.EnsureCharacterBankAccounts({ characterId = characterId, accountRef = 'live-test-1' }, 'feather-economy')
        assert(replayBanks.ok and replayBanks.value[1].accountId == banks.value[1].accountId
            and second.value[1].accountId ~= banks.value[1].accountId, 'multi-account identity failed')
        local function Find(list, currency)
            for _, account in ipairs(list) do if account.currency == currency then return account end end
        end
        local wallet, bank = Find(wallets.value, 'dollars'), Find(banks.value, 'dollars')
        local walletStart, bankStart = wallet.balance, bank.balance
        local sink = EconomyAPI.GetSystemAccount({ currency = 'dollars', accountType = 'system_sink' }, 'feather-economy')
        assert(sink.ok, 'system sink unavailable')
        local function Move(from, to, amount, reason, key, resource)
            return EconomyAPI.Transfer({ fromAccountId = from.accountId, toAccountId = to.accountId,
                currency = 'dollars', amount = amount, reasonCode = reason, idempotencyKey = requestId .. ':' .. key
            }, { actorCharacterId = characterId }, resource or 'feather-economy')
        end
        local funded = EconomyAPI.Issue({ accountId = wallet.accountId, currency = 'dollars', amount = 1000,
            reasonCode = 'bank.test_funding', idempotencyKey = requestId .. ':fund' }, {}, 'feather-economy')
        assert(funded.ok, 'funding failed: ' .. tostring(funded.code))
        local deposit = Move(wallet, bank, 600, 'bank.deposit', 'deposit')
        assert(deposit.ok, 'deposit failed: ' .. tostring(deposit.code))
        local replay = Move(wallet, bank, 600, 'bank.deposit', 'deposit')
        assert(replay.ok and replay.value.replayed == true and replay.value.transactionId == deposit.value.transactionId, 'deposit replay failed')
        local overdraw = Move(bank, wallet, 601, 'bank.withdraw', 'overdraw')
        assert(not overdraw.ok and overdraw.code == 'insufficient_funds', 'overdraw was not rejected')
        local withdraw = Move(bank, wallet, 100, 'bank.withdraw', 'withdraw')
        assert(withdraw.ok, 'withdraw failed: ' .. tostring(withdraw.code))
        local fee = Move(bank, sink.value, 50, 'bank.fee', 'fee')
        assert(fee.ok, 'fee failed: ' .. tostring(fee.code))
        local history = EconomyAPI.ListAccountEntries({ accountId = bank.accountId, limit = 10 }, 'feather-economy')
        assert(history.ok and #history.value >= 3 and history.value[1].reasonCode == 'bank.fee'
            and history.value[1].amount == -50, 'history did not list the fee first')
        -- Return the test funds: bank 450 -> wallet, then destroy the 1000 - 50 from the wallet.
        local back = Move(bank, wallet, 450, 'bank.withdraw', 'return')
        assert(back.ok, 'return failed: ' .. tostring(back.code))
        local removed = EconomyAPI.Destroy({ accountId = wallet.accountId, currency = 'dollars', amount = 950,
            reasonCode = 'bank.test_cleanup', idempotencyKey = requestId .. ':cleanup' }, {}, 'feather-economy')
        assert(removed.ok, 'cleanup failed: ' .. tostring(removed.code))
        local walletEnd = EconomyAccounts.Get(wallet.accountId).value.balance
        local bankEnd = EconomyAccounts.Get(bank.accountId).value.balance
        assert(walletEnd == walletStart and bankEnd == bankStart, ('balances not restored wallet %d->%d bank %d->%d')
            :format(walletStart, walletEnd, bankStart, bankEnd))
        print(('[EconomyBankLiveTest] PASS deposit/withdraw/fee/replay/overdraw/history verified; wallet=%d bank=%d restored'):format(walletEnd, bankEnd))
    end, debug.traceback)
    if not called then print('[EconomyBankLiveTest] FAIL ' .. tostring(failure)) end
end, true)
