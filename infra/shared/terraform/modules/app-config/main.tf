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
resource "azurecaf_name" "azurerm_app_config" {
  name          = var.application_name
  resource_type = "azurerm_app_configuration"
  suffixes      = [var.environment]
}


# Create Azure App Configuration

resource "azurerm_app_configuration" "app_config" {
  name                = azurecaf_name.azurerm_app_config.result
  resource_group_name = var.resource_group
  location            = var.location

  public_network_access = var.environment == "prod" ? false : true

  identity {
    type = "SystemAssigned"
  }

  purge_protection_enabled = var.environment == "prod" ? true : false

  sku = var.environment == "prod" ? "Standard" : "Free"

  dynamic "replica" {
    for_each = var.replica_location != null ? [var.replica_location] : []
    content{
        location = replica.value
        name = "${replica.value}-${azurecaf_name.azurerm_app_config.result}"
    }
  }
}

# Create role assignments

resource "azurerm_role_assignment" "azconfig_reader_user_role_assignment" {
  scope                = azurecaf_name.azurerm_app_config.id
  role_definition_name = "App Configuration Data Reader"
  principal_id         = var.aca_identity_principal_id
}

# For demo purposes, allow current user access to the app config
# Note: when running as a service principal, this is also needed

resource "azurerm_role_assignment" "azconfig_owner_user_role_assignment" {
  scope                = azurecaf_name.azurerm_app_config.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azuread_client_config.current.object_id
}

# Create Private DNS Zone and Endpoint for App Configuration

resource "azurerm_private_dns_zone" "dns_for_azconfig" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "privatelink.azconfig.io"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "virtual_network_link_azconfig" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "privatelink.azconfig.io"
  private_dns_zone_name = azurerm_private_dns_zone.dns_for_azconfig[0].name
  virtual_network_id    = var.spoke_vnet_id
  resource_group_name   = var.resource_group
}

resource "azurerm_private_endpoint" "azconfig_pe" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "private-endpoint-ac"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "privatednsazconfigzonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_for_azconfig[0].id]
  }

  private_service_connection {
    name                           = "peconnection-azconfig"
    private_connection_resource_id = azurecaf_name.azurerm_app_config.id
    is_manual_connection           = false
    subresource_names              = ["configurationStores"]
  }
}
