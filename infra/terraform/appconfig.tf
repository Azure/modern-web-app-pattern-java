
# ----------------------------------------------------------------------------------------------
#  App Config - Prod
# ----------------------------------------------------------------------------------------------

module "azconfig" {
  count                      = var.environment == "prod" ? 1 : 0
  source                     = "../shared/terraform/modules/app-config"
  resource_group             = azurerm_resource_group.hub[0].name
  application_name           = var.application_name
  environment                = var.environment
  location                   = var.location
  aca_identity_principal_id  = module.aca[0].identity_principal_id
  hub_vnet_id                = module.hub_vnet[0].vnet_id
  replica_location           = var.secondary_location
  keys                       = local.azconfig_keys
  private_endpoint_subnet_id = module.hub_vnet[0].subnets[local.private_link_subnet_name].id
}


# ----------------------------------------------------------------------------------------------
#  App Config - Dev
# ----------------------------------------------------------------------------------------------

module "dev_azconfig" {
  count                     = var.environment == "dev" ? 1 : 0
  source                    = "../shared/terraform/modules/app-config"
  resource_group            = azurerm_resource_group.dev[0].name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  aca_identity_principal_id = module.dev_aca[0].identity_principal_id
  keys                      = local.azconfig_keys
  hub_vnet_id               = null
}
