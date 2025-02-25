terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

data "azuread_client_config" "current" {}

# Container Registry naming convention using azurecaf_name module.
resource "azurecaf_name" "azurerm_container_registry" {
  name          = var.application_name
  resource_type = "azurerm_container_registry"
  suffixes      = [var.environment]
}


# Create Azure Container Registry

resource "azurerm_container_registry" "acr" {
  name                = azurecaf_name.azurerm_container_registry.result
  resource_group_name = var.resource_group
  location            = var.location

  sku = var.environment == "prod" ? "Premium" : "Basic"

  admin_enabled                 = false
  network_rule_bypass_option    = "AzureServices"
  public_network_access_enabled = var.environment == "prod" ? false : true
  zone_redundancy_enabled       = var.environment == "prod" ? true : false

  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location = georeplications.value.location
    }

  }
  #│ `network_rule_set_set` can only be specified for a Premium Sku -> prod.
  dynamic "network_rule_set" {
    for_each = var.network_rules != null && var.environment == "prod" ? { this = var.network_rules } : {}
    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rules
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }
}

# Create role assignments

resource "azurerm_role_assignment" "container_app_acr_pull" {
  principal_id         = var.aca_identity_principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_user_assigned_identity" "container_registry_user_assigned_identity" {
  name                = "ContainerRegistryUserAssignedIdentity"
  resource_group_name = var.resource_group
  location            = var.location
}

resource "azurerm_role_assignment" "container_registry_user_assigned_identity_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container_registry_user_assigned_identity.principal_id
}


# For demo purposes, allow current user access to the container registry
# Note: when running as a service principal, this is also needed
resource "azurerm_role_assignment" "acr_contributor_user_role_assignement" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_client_config.current.object_id
}

