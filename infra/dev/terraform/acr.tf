resource "azurerm_container_registry" "acr" {
  name                = var.application_name
  resource_group_name = azurerm_resource_group.dev.name
  location            = var.location

  sku = "Premium"

  admin_enabled                 = false
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  network_rule_set {
    default_action             = "Deny"
    ip_rule {
      action = "Allow"
      ip_range  = local.mynetwork
    }
  }
}

resource "azurerm_role_assignment" "container_app_acr_pull" {
  principal_id                     = azurerm_container_app.container_app.identity[0].principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
}


# For demo purposes, allow current user access to the key vault
# Note: when running as a service principal, this is also needed
resource azurerm_role_assignment acr_contributor_user_role_assignement {
  scope                 = azurerm_container_registry.acr.id
  role_definition_name  = "Contributor"
  principal_id          = data.azuread_client_config.current.object_id
}
