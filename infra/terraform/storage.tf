
# ----------------------------------------------------------------------------------------------
#  Storage - Prod - Primary Region
# ----------------------------------------------------------------------------------------------

module "storage" {
  count               = var.environment == "prod" ? 1 : 0
  source              = "../shared/terraform/modules/storage"
  resource_group      = azurerm_resource_group.spoke[0].name
  application_name    = var.application_name
  environment         = var.environment
  location            = var.location
  principal_id        = module.application[0].application_principal_id
  ip_rules            = [local.mynetwork]
}


# ----------------------------------------------------------------------------------------------
#  Storage - Prod - Secondary Region
# ----------------------------------------------------------------------------------------------

module "secondary_storage" {
  count               = var.environment == "prod" ? 1 : 0
  source              = "../shared/terraform/modules/storage"
  resource_group      =  azurerm_resource_group.secondary_spoke[0].name
  application_name    = var.application_name
  environment         = var.environment
  location            = var.location
  principal_id        = module.secondary_application[0].application_principal_id
  ip_rules            = [local.mynetwork]
}

# ----------------------------------------------------------------------------------------------
# Storage - Dev
# ----------------------------------------------------------------------------------------------

module "dev_storage" {
  count               = var.environment == "dev" ? 1 : 0
  source              = "../shared/terraform/modules/storage"
  resource_group      = azurerm_resource_group.dev[0].name
  application_name    = var.application_name
  environment         = var.environment
  location            = var.location
  principal_id        = module.dev_application[0].application_principal_id
  ip_rules            = [local.mynetwork]
}