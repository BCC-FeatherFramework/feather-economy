EconomyMigrationDefinitions = EconomyMigrationDefinitions or {}

-- Bank reserves. An organization treasury becomes a bank reserve when a trusted
-- bank provisioner binds it; the binding is permanent and names the one resource
-- that may move reserve funds with bank.* reason codes. Other treasuries (shops,
-- governments) can never be drained through bank reasons.
EconomyMigrationDefinitions[#EconomyMigrationDefinitions + 1] = {
    id = '006_bank_reserves',
    statements = {
        [[CREATE TABLE IF NOT EXISTS `economy_bank_reserves` (
            `organization_id` CHAR(36) NOT NULL,
            `operator_resource` VARCHAR(100) NOT NULL,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`organization_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]]
    }
}
