terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

# Create App Configuration Keys

resource "azurerm_app_configuration_key" "primary_keys" {
  for_each               = var.primary_app_config_keys != null ? { for idx, key in var.primary_app_config_keys : idx => key } : {}
  configuration_store_id = var.primary_app_config_id
  key                    = each.value.key
  type                   = each.value.type
  content_type           = each.value.type == "kv" ? each.value.content_type : null
  value                  = each.value.type == "kv" ? each.value.value : null
  vault_key_reference    = each.value.type == "vault" ? each.value.vault_key_reference : null
  label                  = each.value.label
  locked                 = each.value.locked
}

resource "azurerm_app_configuration_key" "secondary_keys" {
  for_each               = var.secondary_app_config_keys != null ? { for idx, key in var.secondary_app_config_keys : idx => key } : {}
  configuration_store_id = var.secondary_app_config_id
  key                    = each.value.key
  type                   = each.value.type
  content_type           = each.value.type == "kv" ? each.value.content_type : null
  value                  = each.value.type == "kv" ? each.value.value : null
  vault_key_reference    = each.value.type == "vault" ? each.value.vault_key_reference : null
  label                  = each.value.label
  locked                 = each.value.locked
}