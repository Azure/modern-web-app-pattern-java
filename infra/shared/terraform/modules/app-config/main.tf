terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

data "azuread_client_config" "current" {}

# App Configuration naming convention using azurecaf_name module.
resource "azurecaf_name" "azurerm_app_config" {
  name          = var.application_name
  resource_type = "azurerm_app_configuration"
  suffixes      = [var.location, var.environment]
}

# Create Azure App Configuration

resource "azurerm_app_configuration" "app_config" {
  name                = azurecaf_name.azurerm_app_config.result
  resource_group_name = var.resource_group
  location            = var.location

  sku = var.environment == "prod" ? "standard" : "free"

  purge_protection_enabled = var.environment == "prod" ? true : false

  public_network_access = var.environment == "prod" ? "Disabled" : "Enabled"

  local_auth_enabled = var.environment == "prod" ? false : true

  dynamic "replica" {
    for_each = var.replica_location != null ? [var.replica_location] : []
    content {
      location = replica.value
      name     = "AppConfig${var.environment}${replica.value}"
    }
  }
}

# Create App Configuration Features

resource "azurerm_app_configuration_feature" "feature" {
  for_each               = var.features != null ? { for idx, feature in var.features : idx => feature } : {}
  configuration_store_id = azurerm_app_configuration.app_config.id
  description            = each.value.description
  name                   = each.value.name

  enabled = each.value.enabled
  locked  = each.value.locked
  label   = each.value.label
}

# Create App Configuration Keys

resource "azurerm_app_configuration_key" "key" {
  for_each               = var.keys != null ? { for idx, key in var.keys : idx => key } : {}
  configuration_store_id = azurerm_app_configuration.app_config.id
  key                    = each.value.key
  type                   = each.value.type
  content_type           = each.value.type == "kv" ? each.value.content_type : null
  value                  = each.value.type == "kv" ? each.value.value : null
  vault_key_reference    = each.value.type == "vault" ? each.value.vault_key_reference : null
  label                  = each.value.label
  locked                 = each.value.locked
}

# Create role assignments

resource "azurerm_role_assignment" "app_service_reader_user_role_assignment" {
  principal_id         = var.app_service_identity_principal_id
  role_definition_name = "App Configuration Data Reader"
  scope                = azurerm_app_configuration.app_config.id
}

# For demo purposes, allow current user access to the app config
# Note: when running as a service principal, this is also needed

resource "azurerm_role_assignment" "azconfig_owner_user_role_assignment" {
  scope                = azurerm_app_configuration.app_config.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azuread_client_config.current.object_id
}

