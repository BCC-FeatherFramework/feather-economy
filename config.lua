Config = {
    Contract = 1,
    RequiredCoreContract = 1,
    -- Registers the data-changing console tests and the migration fault switch.
    -- Development servers only; keep false for production.
    DevMode = false,
    SystemOwnerId = '00000000-0000-0000-0000-000000000001',
    -- Resources allowed to call each group of exports (README "Access groups").
    -- Besides the Feather resources, this server trusts its ported consumers:
    --   bcc-banks    bank accounts, statements, branch reserves (operated treasuries)
    --   bcc-society  business treasuries: deposits, withdrawals, payroll, bills, tax
    --   bcc-stables  horse and tack purchases; sales pay out with Issue (see trustedSuppliers)
    --   bcc-shops    store purchases paid into the system sink
    --   bcc-craft    crafting book purchases paid into the system sink
    --   bcc-housing  house purchases, rent, tax; sale back to the agent creates money
    -- Every one of them needs its wallets (trustedProvisioners) and reads accounts
    -- (trustedReaders) to pay; only the groups noted below grant more.
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
            ['bcc-banks'] = true,    -- one account per character and branch
            ['feather-admin'] = true
        },
        -- May register reason codes whose shapes move character bank accounts.
        -- They must also be in trustedTransactors.
        trustedBankTransactors = {
            ['feather-economy'] = true,
            ['bcc-banks'] = true     -- deposits, withdrawals, transfers, fees, loans, checks
        },
        -- May bind organization treasuries (EnsureOperatedTreasury) and register
        -- reason codes whose shapes move them. They must also be in trustedTransactors.
        trustedTreasuryOperators = {
            ['bcc-banks'] = true,    -- the reserve treasury of each branch
            ['bcc-society'] = true   -- the treasury of each business
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
            ['feather-contracts'] = true, -- reconciles settlements with GetTransaction
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
            ['feather-contracts'] = true, -- settles obligations such as rent and tax
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
            -- Sale back to the housing agent and furniture sell-back. Also needs the
            -- economy.currency.issue grant in the policy provider.
            ['bcc-housing'] = true
            -- bcc-stables is not listed: its horse sales (StablesEconomy.Payout) issue
            -- currency and are refused until it is added here and granted
            -- economy.currency.issue.
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
    -- Issue and Destroy need an explicit Core policy grant (issueAction or
    -- destroyAction) for the calling resource. Keep enabled for production;
    -- trust lists alone never allow creating or destroying currency.
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
