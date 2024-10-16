
# ----------------------------------------------------------------------------------------------
#  Primary App Config - Prod
# ----------------------------------------------------------------------------------------------

module "azconfig" {
  count                             = var.environment == "prod" ? 1 : 0
  source                            = "../shared/terraform/modules/app-config"
  resource_group                    = azurerm_resource_group.spoke[0].name
  application_name                  = var.application_name
  environment                       = var.environment
  location                          = var.location
  spoke_vnet_id                     = module.spoke_vnet[0].vnet_id
  keys                              = []
  private_endpoint_subnet_id        = module.spoke_vnet[0].subnets[local.private_link_subnet_name].id
  app_service_identity_principal_id = module.application[0].application_principal_id
}

#----------------------------------------------------------------------------------------------
# Secondary App Config - Prod
#----------------------------------------------------------------------------------------------

module "secondary_azconfig" {
  count                             = var.environment == "prod" ? 1 : 0
  source                            = "../shared/terraform/modules/app-config"
  resource_group                    = azurerm_resource_group.secondary_spoke[0].name
  application_name                  = var.application_name
  environment                       = var.environment
  location                          = var.secondary_location
  spoke_vnet_id                     = module.secondary_spoke_vnet[0].vnet_id
  keys                              = []
  private_endpoint_subnet_id        = module.secondary_spoke_vnet[0].subnets[local.private_link_subnet_name].id
  app_service_identity_principal_id = module.secondary_application[0].application_principal_id
}

# ----------------------------------------------------------------------------------------------
#  App Config - Dev
# ----------------------------------------------------------------------------------------------

module "dev_azconfig" {
  count                             = var.environment == "dev" ? 1 : 0
  source                            = "../shared/terraform/modules/app-config"
  resource_group                    = azurerm_resource_group.dev[0].name
  application_name                  = var.application_name
  environment                       = var.environment
  location                          = var.location
  keys                              = local.dev_azconfig_keys
  spoke_vnet_id                     = null
  app_service_identity_principal_id = module.dev_application[0].application_principal_id
}
