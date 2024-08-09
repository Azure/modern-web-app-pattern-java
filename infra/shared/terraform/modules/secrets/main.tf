terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

resource "azurerm_key_vault_secret" "key_vault_secret" {
  for_each    = var.secrets
  name        = each.key
  value       = each.value
  key_vault_id = var.key_vault_id
}
