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
        -- Operated accounts (extension, off by default). See README "Operated accounts".
        -- May provision character bank accounts (EnsureCharacterBankAccounts).
        -- Example: ['bcc-banks'] = true.
        trustedBankProvisioners = {
            ['feather-economy'] = true
        },
        -- May register reason codes whose shapes move character bank accounts.
        -- Also needs trustedTransactors. Example: ['bcc-banks'] = true.
        trustedBankTransactors = {
            ['feather-economy'] = true
        },
        -- May bind organization treasuries (EnsureOperatedTreasury) and register
        -- reason codes whose shapes move them. Also needs trustedTransactors.
        -- Example: ['bcc-society'] = true, ['bcc-banks'] = true.
        trustedTreasuryOperators = {},
        -- May read the journal history of any account (ListAccountEntries). Other
        -- trusted readers see only accounts they serve.
        privilegedHistoryReaders = {
            ['feather-economy'] = true,
            ['feather-admin'] = true
        },
        trustedReaders = {
            ['feather-economy'] = true,
            ['feather-admin'] = true,
            ['feather-hud'] = true,
            ['feather-shops'] = true
        },
        trustedProvisioners = {
            ['feather-economy'] = true,
            ['feather-character'] = true,
            ['feather-shops'] = true,
            ['feather-admin'] = true
        },
        trustedTransactors = {
            ['feather-economy'] = true,
            ['feather-shops'] = true
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
    -- Reason codes an operator may create currency with (issue_to_bank and
    -- issue_to_operated shapes), per resource, exact match only. Empty: no operator
    -- supply. Each issue still needs a Core policy grant (economy.currency.issue).
    -- Example: ['bcc-banks'] = { ['bank.migration.import'] = true, ['bank.reserve.funding'] = true }
    OperatorSupply = {},
    Authorization = {
        enabled = true,
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
