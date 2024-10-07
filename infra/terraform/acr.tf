
# ----------------------------------------------------------------------------------------------
#  ACR - Prod
# ----------------------------------------------------------------------------------------------

module "acr" {
  count                      = var.environment == "prod" ? 1 : 0
  source                     = "../shared/terraform/modules/acr"
  resource_group             = azurerm_resource_group.hub[0].name
  application_name           = var.application_name
  environment                = var.environment
  location                   = var.location
  aca_identity_principal_id  = module.aca[0].identity_principal_id
  private_endpoint_subnet_id = module.spoke_vnet[0].subnets[local.private_link_subnet_name].id
  network_rules = {
    default_action = "Allow"
    ip_rules = [
      {
        action   = "Allow"
        ip_range = local.mynetwork
      }
    ]
  }
  hub_vnet_id = module.hub_vnet[0].vnet_id
}


# ----------------------------------------------------------------------------------------------
#  ACR - Dev
# ----------------------------------------------------------------------------------------------

module "dev_acr" {
  count                     = var.environment == "dev" ? 1 : 0
  source                    = "../shared/terraform/modules/acr"
  resource_group            = azurerm_resource_group.dev[0].name
  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  aca_identity_principal_id = module.dev_aca[0].identity_principal_id
  network_rules = {
    default_action = "Allow"
    ip_rules = [
      {
        action   = "Allow"
        ip_range = local.mynetwork
      }
    ]
  }
  hub_vnet_id = null
}
