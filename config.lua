Config = {
    Contract = 1,
    RequiredCoreContract = 1,
    DevMode = false,
    SystemOwnerId = '00000000-0000-0000-0000-000000000001',
    Access = {
        trustedTreasuryProvisioners = {
            ['feather-economy'] = true,
            ['feather-shops'] = true,
            ['feather-admin'] = true
        },
        -- May provision character bank accounts and bind bank reserves.
        trustedBankProvisioners = {
            ['feather-economy'] = true,
            ['bcc-banks'] = true,
            ['feather-admin'] = true
        },
        -- Callers allowed to use the bank.* reason codes (deposit, withdraw,
        -- transfer, fee, reserve settlements). They must also be in trustedTransactors.
        trustedBankTransactors = {
            ['feather-economy'] = true,
            ['bcc-banks'] = true
        },
        -- Callers that may bind and operate an organization treasury with
        -- society.* reasons (EnsureOperatedTreasury). They must also be in
        -- trustedTransactors.
        trustedTreasuryOperators = {
            ['bcc-society'] = true
        },
        -- May read the journal history of any account (ListAccountEntries). Other
        -- trusted readers see only accounts they serve: bank transactors read bank
        -- accounts, treasury operators read the treasury bound to them.
        privilegedHistoryReaders = {
            ['feather-economy'] = true,
            ['feather-admin'] = true
        },
        trustedReaders = {
            ['feather-economy'] = true,
            ['feather-admin'] = true,
            ['feather-hud'] = true,
            ['feather-shops'] = true,
            ['bcc-banks'] = true,
            ['bcc-society'] = true,
            ['bcc-stables'] = true,
            ['bcc-shops'] = true,
            ['bcc-craft'] = true
        },
        trustedProvisioners = {
            ['feather-economy'] = true,
            ['feather-character'] = true,
            ['feather-shops'] = true,
            ['feather-admin'] = true,
            ['bcc-banks'] = true,
            ['bcc-society'] = true,
            ['bcc-stables'] = true,
            ['bcc-shops'] = true,
            ['bcc-craft'] = true
        },
        trustedTransactors = {
            ['feather-economy'] = true,
            ['feather-shops'] = true,
            ['bcc-banks'] = true,
            ['bcc-society'] = true,
            ['bcc-stables'] = true,
            ['bcc-shops'] = true,
            ['bcc-craft'] = true
        },
        trustedReversers = {
            ['feather-economy'] = true,
            ['feather-shops'] = true
        },
        trustedSuppliers = {
            ['feather-economy'] = true,
            ['feather-admin'] = true
        }
    },
    -- Reason codes under which a bank resource may create or destroy currency.
    -- Exact match only; anything not listed here is denied for that resource.
    BankSupply = {
        -- Loans, checks, box fees and gold exchange settle against the branch
        -- reserve (see EnsureBankReserve); only the one-time balance import and
        -- operator funding of a reserve still create currency.
        ['bcc-banks'] = {
            ['bank.migration.import'] = true,
            ['bank.reserve.funding'] = true
        }
    },
    Authorization = {
        enabled = true,
        -- When true, supply operations that match an exact Config.BankSupply entry
        -- skip the Core policy check. Keep false: the Economy master plan requires
        -- the trusted-resource and policy gates to stay independent. Bank supply is
        -- granted in feather-admin configs/service_policy.lua
        -- (['feather-economy']['bcc-banks']['economy.currency.issue']).
        exemptBankSupply = false,
        issueAction = 'economy.currency.issue',
        destroyAction = 'economy.currency.destroy'
    },
    Outbox = {
        pollIntervalMs = 1000,
        retryDelaySeconds = 5,
        batchSize = 25
    },
    Currencies = {
        dollars = {
            label = 'Dollars',
            precision = 2,
            enabled = true
        },
        gold = {
            label = 'Gold',
            precision = 2,
            enabled = true
        }
    },
    Limits = {
        readinessTimeoutMs = 30000,
        maximumPageSize = 100,
        maximumReasonLength = 64,
        maximumReferenceLength = 128,
        maximumIdempotencyKeyLength = 128,
        maximumTransferAmount = 1000000000000,
        maximumBalance = 9000000000000000
    }
}
