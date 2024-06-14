module "dev_key_vault" {
  source                     = "../shared/terraform/modules/key-vault"
  resource_group             = azurerm_resource_group.dev.name
  application_name           = var.application_name
  environment                = var.environment
  location                   = var.location
  azure_ad_tenant_id         = data.azuread_client_config.current.tenant_id
}


# Give the app access to the key vault secrets - https://learn.microsoft.com/azure/key-vault/general/rbac-guide?tabs=azure-cli#secret-scope-role-assignment
resource azurerm_role_assignment dev_app_keyvault_role_assignment {
  scope                 = module.dev_key_vault.vault_id
  role_definition_name  = "Key Vault Secrets User"
  principal_id          = module.dev_application.application_principal_id
}
