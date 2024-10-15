
locals {
  contoso_tenant_id       = data.azuread_client_config.current.tenant_id
  dev_contoso_client_id   = var.environment == "dev" ? module.dev_ad[0].application_registration_id : null
  prod_contoso_client_id  = var.environment == "prod" ? module.ad[0].application_registration_id : null
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

module "secrets" {
  count        = var.environment == "prod" ? 1 : 0
  source                         = "../shared/terraform/modules/secrets"
  key_vault_id = module.hub_key_vault[0].vault_id
  depends_on = [
    azurerm_role_assignment.kv_administrator_user_role_assignement
  ]
  secrets = {
    "contoso-application-tenant-id"          = local.contoso_tenant_id
    "contoso-application-client-id"          = local.prod_contoso_client_id
    "contoso-application-client-secret"      = module.ad[0].application_client_secret
    "contoso-database-admin"                 = module.postresql_database[0].database_username
    "contoso-database-admin-password"        = local.database_administrator_password
    "contoso-app-insights-connection-string" = module.hub_app_insights[0].connection_string
    "contoso-redis-password"                 = module.cache[0].cache_secret
    "contoso-jumpbox-username"               = var.jumpbox_username
    "contoso-jumpbox-password"               = random_password.jumpbox_password.result
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
    "contoso-application-tenant-id"          = local.contoso_tenant_id
    "contoso-application-client-id"          = local.dev_contoso_client_id
    "contoso-application-client-secret"      = module.dev_ad[0].application_client_secret
    "contoso-database-admin"                 = module.dev_postresql_database[0].database_username
    "contoso-database-admin-password"        = local.database_administrator_password
    "contoso-app-insights-connection-string" = module.dev_app_insights[0].connection_string
    "contoso-redis-password"                 = module.dev_cache[0].cache_secret
  }
}
