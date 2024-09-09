// ---------------------------------------------------------------------------
//  Production
// ---------------------------------------------------------------------------

# ---------------------
#  Primary App Service
# ---------------------

module "application" {
  count                          = var.environment == "prod" ? 1 : 0
  source                         = "../shared/terraform/modules/app-service"
  resource_group                 = azurerm_resource_group.spoke[0].name
  application_name               = var.application_name
  environment                    = var.environment
  location                       = var.location
  private_dns_resource_group     = azurerm_resource_group.hub[0].name
  appsvc_subnet_id               = module.spoke_vnet[0].subnets[local.app_service_subnet_name].id
  private_endpoint_subnet_id     = module.spoke_vnet[0].subnets[local.private_link_subnet_name].id
  app_insights_connection_string = module.hub_app_insights[0].connection_string
  app_insights_instrumentation_key = module.hub_app_insights[0].instrumentation_key
  log_analytics_workspace_id     = module.hub_app_insights[0].log_analytics_workspace_id
  frontdoor_host_name            = module.frontdoor[0].host_name
  frontdoor_profile_uuid         = module.frontdoor[0].resource_guid
  public_network_access_enabled  = false

  contoso_webapp_options = {
     contoso_active_directory_tenant_id     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.contoso_application_tenant_id[0].id})"
    contoso_active_directory_client_id     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.contoso_application_client_id[0].id})"
    contoso_active_directory_client_secret = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.contoso_application_client_secret[0].id})"
    postgresql_database_url                = format("@Microsoft.KeyVault(SecretUri=%s)", module.secrets[0].secret_names["contoso-database-url"])
    postgresql_database_user               = format("@Microsoft.KeyVault(SecretUri=%s)", module.secrets[0].secret_names["contoso-database-admin"])
    postgresql_database_password           = format("@Microsoft.KeyVault(SecretUri=%s)", module.secrets[0].secret_names["contoso-database-admin-password"])
    redis_host_name                        = module.cache[0].cache_hostname
    redis_port                             = module.cache[0].cache_ssl_port
    redis_password                         = format("@Microsoft.KeyVault(SecretUri=%s)", module.secrets[0].secret_names["contoso-redis-password"])
    service_bus_namespace                  = format("@Microsoft.KeyVault(SecretUri=%s)", module.secrets[0].secret_names["contoso-servicebus-namespace"])
    service_bus_email_request_queue        = format("@Microsoft.KeyVault(SecretUri=%s)", module.secrets[0].secret_names["contoso-email-request-queue"])
    service_bus_email_response_queue       = format("@Microsoft.KeyVault(SecretUri=%s)", module.secrets[0].secret_names["contoso-email-response-queue"])
    storage_account_name                   = format("@Microsoft.KeyVault(SecretUri=%s)", module.secrets[0].secret_names["contoso-storage-account"])
    storage_container_name                 = format("@Microsoft.KeyVault(SecretUri=%s)", module.secrets[0].secret_names["contoso-storage-container-name"])
  }
}

# -----------------------
#  Secondary App Service
# -----------------------

module "secondary_application" {
  count                          = var.environment == "prod" ? 1 : 0
  source                         = "../shared/terraform/modules/app-service"
  resource_group                 = azurerm_resource_group.secondary_spoke[0].name
  application_name               = var.application_name
  environment                    = var.environment
  location                       = var.secondary_location
  private_dns_resource_group     = azurerm_resource_group.hub[0].name
  appsvc_subnet_id               = module.secondary_spoke_vnet[0].subnets[local.app_service_subnet_name].id
  private_endpoint_subnet_id  = module.secondary_spoke_vnet[0].subnets[local.private_link_subnet_name].id
  app_insights_connection_string = module.hub_app_insights[0].connection_string
  app_insights_instrumentation_key = module.hub_app_insights[0].instrumentation_key
  log_analytics_workspace_id     = module.hub_app_insights[0].log_analytics_workspace_id
  frontdoor_host_name            = module.frontdoor[0].host_name
  frontdoor_profile_uuid         = module.frontdoor[0].resource_guid
  public_network_access_enabled  = false

  contoso_webapp_options = {
    contoso_active_directory_tenant_id     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.contoso_application_tenant_id[0].id})"
    contoso_active_directory_client_id     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.contoso_application_client_id[0].id})"
    contoso_active_directory_client_secret = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.contoso_application_client_secret[0].id})"
    postgresql_database_url                = format("@Microsoft.KeyVault(SecretUri=%s)", module.secondary_secrets[0].secret_names["secondary-contoso-database-url"])
    postgresql_database_user               = format("@Microsoft.KeyVault(SecretUri=%s)", module.secondary_secrets[0].secret_names["secondary-contoso-database-admin"])
    postgresql_database_password           = format("@Microsoft.KeyVault(SecretUri=%s)", module.secondary_secrets[0].secret_names["secondary-contoso-database-admin-password"])
    redis_host_name                        = module.secondary_cache[0].cache_hostname
    redis_port                             = module.secondary_cache[0].cache_ssl_port
    redis_password                         = format("@Microsoft.KeyVault(SecretUri=%s)", module.secondary_secrets[0].secret_names["secondary-contoso-redis-password"])
    service_bus_namespace                  = format("@Microsoft.KeyVault(SecretUri=%s)", module.secondary_secrets[0].secret_names["secondary-contoso-servicebus-namespace"])
    service_bus_email_request_queue        = format("@Microsoft.KeyVault(SecretUri=%s)", module.secondary_secrets[0].secret_names["secondary-contoso-email-request-queue"])
    service_bus_email_response_queue       = format("@Microsoft.KeyVault(SecretUri=%s)", module.secondary_secrets[0].secret_names["secondary-contoso-email-response-queue"])
    storage_account_name                   = format("@Microsoft.KeyVault(SecretUri=%s)", module.secondary_secrets[0].secret_names["secondary-contoso-storage-account"])
    storage_container_name                 = format("@Microsoft.KeyVault(SecretUri=%s)", module.secondary_secrets[0].secret_names["secondary-contoso-storage-container-name"])

  }

}

// ---------------------------------------------------------------------------
//  Development
// ---------------------------------------------------------------------------

# -------------------
#  Dev - App Service
# -------------------

module "dev_application" {
  count                          = var.environment == "dev" ? 1 : 0
  source                         = "../shared/terraform/modules/app-service"
  resource_group                 = azurerm_resource_group.dev[0].name
  application_name               = var.application_name
  environment                    = var.environment
  location                       = var.location
  private_dns_resource_group     = null
  appsvc_subnet_id               = null
  private_endpoint_subnet_id     = null
  app_insights_connection_string = module.dev_app_insights[0].connection_string
  app_insights_instrumentation_key = module.dev_app_insights[0].instrumentation_key
  log_analytics_workspace_id     = module.dev_app_insights[0].log_analytics_workspace_id
  frontdoor_host_name            = module.dev_frontdoor[0].host_name
  frontdoor_profile_uuid         = module.dev_frontdoor[0].resource_guid
  public_network_access_enabled  = true

  contoso_webapp_options = {
    contoso_active_directory_tenant_id     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.dev_contoso_application_tenant_id[0].id})"
    contoso_active_directory_client_id     = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.dev_contoso_application_client_id[0].id})"
    contoso_active_directory_client_secret = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.dev_contoso_application_client_secret[0].id})"
    postgresql_database_url                = format("@Microsoft.KeyVault(SecretUri=%s)", module.dev_secrets[0].secret_names["dev-contoso-database-url"])
    postgresql_database_user               = format("@Microsoft.KeyVault(SecretUri=%s)", module.dev_secrets[0].secret_names["dev-contoso-database-admin"])
    postgresql_database_password           = format("@Microsoft.KeyVault(SecretUri=%s)", module.dev_secrets[0].secret_names["dev-contoso-database-admin-password"])
    redis_host_name                        = module.dev_cache[0].cache_hostname
    redis_port                             = module.dev_cache[0].cache_ssl_port
    redis_password                         = format("@Microsoft.KeyVault(SecretUri=%s)", module.dev_secrets[0].secret_names["dev-contoso-redis-password"])
    service_bus_namespace                  = format("@Microsoft.KeyVault(SecretUri=%s)", module.dev_secrets[0].secret_names["dev-contoso-servicebus-namespace"])
    service_bus_email_request_queue        = format("@Microsoft.KeyVault(SecretUri=%s)", module.dev_secrets[0].secret_names["dev-contoso-email-request-queue"])
    service_bus_email_response_queue       = format("@Microsoft.KeyVault(SecretUri=%s)", module.dev_secrets[0].secret_names["dev-contoso-email-response-queue"])
    storage_account_name                   = format("@Microsoft.KeyVault(SecretUri=%s)", module.dev_secrets[0].secret_names["dev-contoso-storage-account"])
    storage_container_name                 = format("@Microsoft.KeyVault(SecretUri=%s)", module.dev_secrets[0].secret_names["dev-contoso-storage-container-name"])

  }
}
