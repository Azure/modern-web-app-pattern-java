
locals {
  contoso_client_id     = var.environment == "prod" ? module.ad[0].application_registration_id : null
  contoso_tenant_id     = data.azuread_client_config.current.tenant_id
  dev_contoso_client_id = var.environment == "dev" ? module.dev_ad[0].application_registration_id : null
}

# ------
#  Prod
# ------

# For demo purposes, allow current user access to the key vault
# Note: when running as a service principal, this is also needed
resource azurerm_role_assignment kv_administrator_user_role_assignement {
  count                 = var.environment == "prod" ? 1 : 0
  scope                 = module.hub_key_vault[0].vault_id
  role_definition_name  = "Key Vault Administrator"
  principal_id          = data.azuread_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "jumpbox_username" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "Jumpbox--AdministratorUsername"
  value        = var.jumpbox_username
  key_vault_id = module.hub_key_vault[0].vault_id
  depends_on = [
    azurerm_role_assignment.kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "jumpbox_password_secret" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "Jumpbox--AdministratorPassword"
  value        = random_password.jumpbox_password.result
  key_vault_id = module.hub_key_vault[0].vault_id
  depends_on = [
    azurerm_role_assignment.kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "contoso_application_tenant_id" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "contoso-application-tenant-id"
  value        = local.contoso_tenant_id
  key_vault_id = module.hub_key_vault[0].vault_id
  depends_on = [
    azurerm_role_assignment.kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "contoso_application_client_id" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "contoso-application-client-id"
  value        = local.contoso_client_id
  key_vault_id = module.hub_key_vault[0].vault_id
  depends_on = [
    azurerm_role_assignment.kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "contoso_application_client_secret" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "contoso-application-client-secret"
  value        = module.ad[0].application_client_secret
  key_vault_id = module.hub_key_vault[0].vault_id
  depends_on = [
    azurerm_role_assignment.kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "contoso_app_insights_connection_string" {
  count        = var.environment == "prod" ? 1 : 0
  name         = "contoso-app-insights-connection-string"
  value        = module.hub_app_insights[0].connection_string
  key_vault_id = module.hub_key_vault[0].vault_id
  depends_on = [
    azurerm_role_assignment.kv_administrator_user_role_assignement
  ]
}

module "secrets" {
  count        = var.environment == "prod" ? 1 : 0
  source                         = "../shared/terraform/modules/secrets"
  key_vault_id = module.hub_key_vault[0].vault_id
  depends_on = [
    azurerm_role_assignment.kv_administrator_user_role_assignement
  ]
  secrets = {
    "contoso-database-admin" = module.postresql_database[0].database_username
    "contoso-database-admin-password" = local.database_administrator_password
    "contoso-servicebus-namespace" = module.servicebus[0].namespace_name
    "contoso-email-request-queue" = module.servicebus[0].queue_email_request_name
    "contoso-email-response-queue" = module.servicebus[0].queue_email_response_name
    "contoso-storage-account"    = module.storage[0].storage_account_name
    "contoso-storage-container-name" = module.storage[0].storage_container_name
    "contoso-redis-password"     = module.cache[0].cache_secret
  }
}


# ----------------------------------------------------------------------------------------------
# 2nd region
# ----------------------------------------------------------------------------------------------
module "secondary_secrets" {
  count        = var.environment == "prod" ? 1 : 0                 
  source       = "../shared/terraform/modules/secrets"
  key_vault_id = module.hub_key_vault[0].vault_id
  depends_on = [
      azurerm_role_assignment.kv_administrator_user_role_assignement
    ]
  secrets = {
  "secondary-contoso-database-url"       = "jdbc:postgresql://${module.secondary_postresql_database[0].database_fqdn}:5432/${azurerm_postgresql_flexible_server_database.postresql_database[0].name}"
  "secondary-contoso-database-admin" = module.secondary_postresql_database[0].database_username
  "secondary-contoso-database-admin-password" = local.database_administrator_password
  "secondary-contoso-servicebus-namespace" = module.secondary_servicebus[0].namespace_name
  "secondary-contoso-email-request-queue" = module.secondary_servicebus[0].queue_email_request_name
  "secondary-contoso-email-response-queue" = module.secondary_servicebus[0].queue_email_response_name
  "secondary-contoso-storage-account"    = module.secondary_storage[0].storage_account_name
  "secondary-contoso-storage-container-name" = module.secondary_storage[0].storage_container_name
  "secondary-contoso-redis-password"     = module.secondary_cache[0].cache_secret
  }
}


# Give the app access to the key vault secrets - https://learn.microsoft.com/azure/key-vault/general/rbac-guide?tabs=azure-cli#secret-scope-role-assignment
resource azurerm_role_assignment app_keyvault_role_assignment {
  count                 = var.environment == "prod" ? 1 : 0
  scope                 = module.hub_key_vault[0].vault_id
  role_definition_name  = "Key Vault Secrets User"
  principal_id          = module.application[0].application_principal_id
}

resource azurerm_role_assignment app_keyvault_role_assignments {
  count                 = var.environment == "prod" ? 1 : 0
  scope                 = module.hub_key_vault[0].vault_id
  role_definition_name  = "Key Vault Secrets User"
  principal_id          = module.secondary_application[0].application_principal_id
}

# ------
#  Dev
# ------

# For demo purposes, allow current user access to the key vault
# Note: when running as a service principal, this is also needed
resource azurerm_role_assignment dev_kv_administrator_user_role_assignement {
  count                 = var.environment == "dev" ? 1 : 0
  scope                 = module.dev_key_vault[0].vault_id
  role_definition_name  = "Key Vault Administrator"
  principal_id          = data.azuread_client_config.current.object_id
}

# Give the app access to the key vault secrets - https://learn.microsoft.com/azure/key-vault/general/rbac-guide?tabs=azure-cli#secret-scope-role-assignment
resource azurerm_role_assignment dev_app_keyvault_role_assignment {
  count                 = var.environment == "dev" ? 1 : 0
  scope                 = module.dev_key_vault[0].vault_id
  role_definition_name  = "Key Vault Secrets User"
  principal_id          = module.dev_application[0].application_principal_id
}


module "dev_secrets" {
  count        = var.environment == "dev" ? 1 : 0
  source                         = "../shared/terraform/modules/secrets"
  key_vault_id = module.dev_key_vault[0].vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
  secrets = {
    "dev-contoso-application-tenant-id" = local.contoso_tenant_id
    "dev-contoso-application-client-id" = local.dev_contoso_client_id
    "dev-contoso-application-client-secret" = module.dev_ad[0].application_client_secret
    "dev-contoso-database-admin" = module.dev_postresql_database[0].database_username
    "dev-contoso-database-admin-password" = local.database_administrator_password
    "dev-contoso-app-insights-connection-string" = module.dev_app_insights[0].connection_string
    "dev-contoso-redis-password"     = module.dev_cache[0].cache_secret
  }
}