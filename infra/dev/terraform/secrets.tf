
locals {
  contoso_tenant_id     = data.azuread_client_config.current.tenant_id
  dev_contoso_client_id = module.dev_application.application_registration_id
}

# For demo purposes, allow current user access to the key vault
# Note: when running as a service principal, this is also needed
resource azurerm_role_assignment dev_kv_administrator_user_role_assignement {
  scope                 = module.dev_key_vault.vault_id
  role_definition_name  = "Key Vault Administrator"
  principal_id          = data.azuread_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "dev_contoso_database_url" {
  name         = "contoso-database-url"
  value        = "jdbc:postgresql://${module.dev_postresql_database.dev_database_fqdn}:5432/${azurerm_postgresql_flexible_server_database.dev_postresql_database_db.name}?sslmode=require"
  key_vault_id = module.dev_key_vault.vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "dev_contoso_database_admin" {
  name         = "contoso-database-admin"
  value        = module.dev_postresql_database.database_username
  key_vault_id = module.dev_key_vault.vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "dev_contoso_database_admin_password" {
  name         = "contoso-database-admin-password"
  value        = local.database_administrator_password
  key_vault_id = module.dev_key_vault.vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "dev_contoso_application_tenant_id" {
  name         = "contoso-application-tenant-id"
  value        = local.contoso_tenant_id
  key_vault_id = module.dev_key_vault.vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "dev_contoso_application_client_id" {
  name         = "contoso-application-client-id"
  value        = local.dev_contoso_client_id
  key_vault_id = module.dev_key_vault.vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "dev_contoso_application_client_secret" {
  name         = "contoso-application-client-secret"
  value        = module.dev_application.application_client_secret
  key_vault_id = module.dev_key_vault.vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "dev_contoso_cache_secret" {
  name         = "contoso-redis-password"
  value        = module.dev-cache.cache_secret
  key_vault_id = module.dev_key_vault.vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
}

###############
resource "azurerm_key_vault_secret" "contoso_servicebus_namespace" {
  name         = "contoso-servicebus-namespace"
  value        = azurerm_servicebus_namespace.servicebus_namespace.name
  key_vault_id = module.dev_key_vault.vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
}

resource "azurerm_key_vault_secret" "contoso_email_request_queue" {
  name         = "contoso-email-request-queue"
  value        = azurerm_servicebus_queue.email_request_queue.name
  key_vault_id = module.dev_key_vault.vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
}


resource "azurerm_key_vault_secret" "contoso_email_response_queue" {
  name         = "contoso-email-response-queue"
  value        = azurerm_servicebus_queue.email_response_queue.name
  key_vault_id = module.dev_key_vault.vault_id
  depends_on = [
    azurerm_role_assignment.dev_kv_administrator_user_role_assignement
  ]
}

# Give the app access to the key vault secrets - https://learn.microsoft.com/azure/key-vault/general/rbac-guide?tabs=azure-cli#secret-scope-role-assignment
resource azurerm_role_assignment dev_app_keyvault_role_assignment {
  scope                 = module.dev_key_vault.vault_id
  role_definition_name  = "Key Vault Secrets User"
  principal_id          = module.dev_application.application_principal_id
}
