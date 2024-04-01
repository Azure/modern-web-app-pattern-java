module "dev_application" {
  source                         = "../shared/terraform/modules/app-service"
  resource_group                 = azurerm_resource_group.dev.name
  application_name               = var.application_name
  environment                    = var.environment
  location                       = var.location

  contoso_webapp_options = {
    contoso_active_directory_tenant_id     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.dev_contoso_application_tenant_id.id})"
    contoso_active_directory_client_id     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.dev_contoso_application_client_id.id})"
    contoso_active_directory_client_secret = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.dev_contoso_application_client_secret.id})"
    postgresql_database_url                = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.dev_contoso_database_url.id})"
    postgresql_database_user               = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.dev_contoso_database_admin.id})"
    postgresql_database_password           = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.dev_contoso_database_admin_password.id})"
    redis_host_name                        = module.dev-cache.cache_hostname
    redis_port                             = module.dev-cache.cache_ssl_port
    redis_password                         = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.dev_contoso_cache_secret.id})"
    service_bus_namespace                  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.contoso_servicebus_namespace.id})"
    service_bus_entity_name                = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.contoso_email_request_queue.id})"
    service_bus_entity_type                = "queue"
  }
}
