module "dev_key_vault" {
  source                     = "../shared/terraform/modules/key-vault"
  resource_group             = azurerm_resource_group.dev.name
  application_name           = var.application_name
  environment                = var.environment
  location                   = var.location
  azure_ad_tenant_id         = data.azuread_client_config.current.tenant_id
}
