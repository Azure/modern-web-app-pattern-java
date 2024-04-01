
module "dev-cache" {
  source                      = "../shared/terraform/modules/cache"
  resource_group              = azurerm_resource_group.dev.name
  environment                 = var.environment
  location                    = var.location
}
