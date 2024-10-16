
# ----------------------------------------------------------------------------------------------
#  Storage - Prod - Primary Region
# ----------------------------------------------------------------------------------------------

module "storage" {
  count               = var.environment == "prod" ? 1 : 0
  source              = "../shared/terraform/modules/storage"
  resource_group      = azurerm_resource_group.spoke[0].name
  application_name    = var.application_name
  environment         = var.environment
  location            = var.location
  ip_rules            = [local.mynetwork]
  account_replication_type = local.account_replication_type
}

resource "azurerm_role_assignment" "storage_container_app_data_contributor_primary" {
  count                = var.environment == "prod" ? 1 : 0
  scope                = module.storage[0].storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.application[0].application_principal_id
}

resource "azurerm_role_assignment" "storage_container_app_data_contributor_secondary" {
  count                = var.environment == "prod" ? 1 : 0
  scope                = module.storage[0].storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.secondary_application[0].application_principal_id
}

# ----------------------------------------------------------------------------------------------
# Storage - Dev
# ----------------------------------------------------------------------------------------------

module "dev_storage" {
  count               = var.environment == "dev" ? 1 : 0
  source              = "../shared/terraform/modules/storage"
  resource_group      = azurerm_resource_group.dev[0].name
  application_name    = var.application_name
  environment         = var.environment
  location            = var.location
  ip_rules            = [local.mynetwork]
  account_replication_type = local.account_replication_type
}

resource "azurerm_role_assignment" "storage_container_app_data_contributor_dev" {
  count               = var.environment == "dev" ? 1 : 0
  scope                = module.dev_storage[0].storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.dev_application[0].application_principal_id
}