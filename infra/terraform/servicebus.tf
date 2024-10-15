
# ----------------------------------------------------------------------------------------------
#  Service Bus - Prod - Primary Region
# ----------------------------------------------------------------------------------------------

module "servicebus" {
  count                               = var.environment == "prod" ? 1 : 0
  source                              = "../shared/terraform/modules/service-bus"
  resource_group                      = azurerm_resource_group.spoke[0].name
  application_name                    = var.application_name
  environment                         = var.environment
  location                            = var.location
  spoke_vnet_id                       = module.spoke_vnet[0].vnet_id
  private_endpoint_subnet_id          = module.spoke_vnet[0].subnets[local.private_link_subnet_name].id
  web_application_principal_id        = module.application[0].application_principal_id
  container_app_identity_principal_id = module.aca[0].identity_principal_id
}
# ----------------------------------------------------------------------------------------------
#  Secondary Servicebus - Prod - Secondary Region
# ----------------------------------------------------------------------------------------------
module "secondary_servicebus" {
  count                               = var.environment == "prod" ? 1 : 0
  source                              = "../shared/terraform/modules/service-bus"
  resource_group                      = azurerm_resource_group.secondary_spoke[0].name
  application_name                    = var.application_name
  environment                         = var.environment
  location                            = var.secondary_location
  spoke_vnet_id                       = module.secondary_spoke_vnet[0].vnet_id
  private_endpoint_subnet_id          = module.secondary_spoke_vnet[0].subnets[local.private_link_subnet_name].id
  web_application_principal_id        = module.secondary_application[0].application_principal_id
  container_app_identity_principal_id = module.secondary_aca[0].identity_principal_id
}

# ----------------------------------------------------------------------------------------------
# Storage - Dev
# ----------------------------------------------------------------------------------------------

module "dev_servicebus" {
  count                               = var.environment == "dev" ? 1 : 0
  source                              = "../shared/terraform/modules/service-bus"
  resource_group                      = azurerm_resource_group.dev[0].name
  application_name                    = var.application_name
  environment                         = var.environment
  location                            = var.location
  web_application_principal_id        = module.dev_application[0].application_principal_id
  container_app_identity_principal_id = module.dev_aca[0].identity_principal_id
}
