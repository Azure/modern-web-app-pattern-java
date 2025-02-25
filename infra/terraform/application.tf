// ---------------------------------------------------------------------------
//  Production
// ---------------------------------------------------------------------------

# ---------------------
#  Primary App Service
# ---------------------

module "application" {
  count                            = var.environment == "prod" ? 1 : 0
  source                           = "../shared/terraform/modules/app-service"
  resource_group                   = azurerm_resource_group.spoke[0].name
  application_name                 = var.application_name
  environment                      = var.environment
  location                         = var.location
  private_dns_resource_group       = azurerm_resource_group.hub[0].name
  appsvc_subnet_id                 = module.spoke_vnet[0].subnets[local.app_service_subnet_name].id
  private_endpoint_subnet_id       = module.spoke_vnet[0].subnets[local.private_link_subnet_name].id
  app_insights_connection_string   = module.hub_app_insights[0].connection_string
  app_insights_instrumentation_key = module.hub_app_insights[0].instrumentation_key
  log_analytics_workspace_id       = module.hub_app_insights[0].log_analytics_workspace_id
  frontdoor_host_name              = module.frontdoor[0].host_name
  frontdoor_profile_uuid           = module.frontdoor[0].resource_guid
  public_network_access_enabled    = false
  app_config_endpoint              = module.azconfig[0].azconfig_uri
}

# -----------------------
#  Secondary App Service
# -----------------------

module "secondary_application" {
  count                            = var.environment == "prod" ? 1 : 0
  source                           = "../shared/terraform/modules/app-service"
  resource_group                   = azurerm_resource_group.secondary_spoke[0].name
  application_name                 = var.application_name
  environment                      = var.environment
  location                         = var.secondary_location
  private_dns_resource_group       = azurerm_resource_group.hub[0].name
  appsvc_subnet_id                 = module.secondary_spoke_vnet[0].subnets[local.app_service_subnet_name].id
  private_endpoint_subnet_id       = module.secondary_spoke_vnet[0].subnets[local.private_link_subnet_name].id
  app_insights_connection_string   = module.hub_app_insights[0].connection_string
  app_insights_instrumentation_key = module.hub_app_insights[0].instrumentation_key
  log_analytics_workspace_id       = module.hub_app_insights[0].log_analytics_workspace_id
  frontdoor_host_name              = module.frontdoor[0].host_name
  frontdoor_profile_uuid           = module.frontdoor[0].resource_guid
  public_network_access_enabled    = false
  app_config_endpoint              = module.secondary_azconfig[0].azconfig_uri

}

// ---------------------------------------------------------------------------
//  Development
// ---------------------------------------------------------------------------

# -------------------
#  Dev - App Service
# -------------------

module "dev_application" {
  count                            = var.environment == "dev" ? 1 : 0
  source                           = "../shared/terraform/modules/app-service"
  resource_group                   = azurerm_resource_group.dev[0].name
  application_name                 = var.application_name
  environment                      = var.environment
  location                         = var.location
  private_dns_resource_group       = null
  appsvc_subnet_id                 = null
  private_endpoint_subnet_id       = null
  app_insights_connection_string   = module.dev_app_insights[0].connection_string
  app_insights_instrumentation_key = module.dev_app_insights[0].instrumentation_key
  log_analytics_workspace_id       = module.dev_app_insights[0].log_analytics_workspace_id
  frontdoor_host_name              = module.dev_frontdoor[0].host_name
  frontdoor_profile_uuid           = module.dev_frontdoor[0].resource_guid
  public_network_access_enabled    = true
  app_config_endpoint              = module.dev_azconfig[0].azconfig_uri
}

resource "null_resource" "dev_service_connector" {
  count               = var.environment == "dev" ? 1 : 0

  triggers = {
    web_app_id = module.dev_application[0].web_app_id
    db_id      = azurerm_postgresql_flexible_server_database.dev_postresql_database_db[0].id
  }
  
  provisioner "local-exec" {
    command = "bash ../scripts/setup-service-connector.sh ${module.dev_application[0].web_app_id} ${azurerm_postgresql_flexible_server_database.dev_postresql_database_db[0].id}"
  }

  depends_on = [
    module.dev_application,
    azurerm_postgresql_flexible_server_database.dev_postresql_database_db,
    azurerm_postgresql_flexible_server_active_directory_administrator.dev-contoso-ad-admin
  ]
}
