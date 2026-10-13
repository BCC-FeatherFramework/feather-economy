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
        -- Operated accounts (README "Operated accounts"). May provision character
        -- bank accounts (EnsureCharacterBankAccounts).
        trustedBankProvisioners = {
            ['feather-economy'] = true,
            ['bcc-banks'] = true,
            ['feather-admin'] = true
        },
        -- May register reason codes whose shapes move character bank accounts.
        -- They must also be in trustedTransactors.
        trustedBankTransactors = {
            ['feather-economy'] = true,
            ['bcc-banks'] = true
        },
        -- May bind organization treasuries (EnsureOperatedTreasury) and register
        -- reason codes whose shapes move them. They must also be in trustedTransactors.
        trustedTreasuryOperators = {
            ['bcc-banks'] = true,
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
            ['bcc-craft'] = true,
            ['bcc-housing'] = true
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
            ['bcc-craft'] = true,
            ['bcc-housing'] = true
        },
        trustedTransactors = {
            ['feather-economy'] = true,
            ['feather-shops'] = true,
            ['bcc-banks'] = true,
            ['bcc-society'] = true,
            ['bcc-stables'] = true,
            ['bcc-shops'] = true,
            ['bcc-craft'] = true,
            ['bcc-housing'] = true
        },
        trustedReversers = {
            ['feather-economy'] = true,
            ['feather-shops'] = true
        },
        trustedSuppliers = {
            ['feather-economy'] = true,
            ['feather-admin'] = true,
            ['bcc-housing'] = true
        }
    },
    -- Reason codes an operator may create currency with (issue_to_bank and
    -- issue_to_operated shapes), per resource, exact match only. Each issue still
    -- needs a Core policy grant (economy.currency.issue) for the resource.
    OperatorSupply = {
        -- Loans, checks, box fees and gold exchange settle against the branch
        -- reserve; only the one-time balance import and funding a reserve create currency.
        ['bcc-banks'] = {
            ['bank.migration.import'] = true,
            ['bank.reserve.funding'] = true
        }
    },
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
