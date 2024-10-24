
# Azure Private DNS provides a reliable, secure DNS service to manage and
# resolve domain names in a virtual network without the need to add a custom DNS solution
# https://docs.microsoft.com/azure/dns/private-dns-privatednszone
#
# After you create a private DNS zone in Azure, you'll need to link a virtual network to it.
# https://docs.microsoft.com/azure/dns/private-dns-virtual-network-links

###############################################
# privatelink.azurewebsites.net
###############################################
resource "azurerm_private_dns_zone" "app_dns_zone" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.hub[0].name
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "spoke-link"
  private_dns_zone_name = azurerm_private_dns_zone.app_dns_zone[0].name
  virtual_network_id    = module.spoke_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name
}

resource "azurerm_private_dns_zone_virtual_network_link" "secondary_spoke_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "secondary-spoke-link"
  private_dns_zone_name = azurerm_private_dns_zone.app_dns_zone[0].name
  virtual_network_id    = module.secondary_spoke_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name
  
  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.spoke_virtual_network_link 
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "hub-link"
  private_dns_zone_name = azurerm_private_dns_zone.app_dns_zone[0].name
  virtual_network_id    = module.hub_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.spoke_virtual_network_link, 
    azurerm_private_dns_zone_virtual_network_link.secondary_spoke_virtual_network_link
  ]
}

###############################################
# privatelink.postgres.database.azure.com
###############################################
resource "azurerm_private_dns_zone" "postgres_dns_zone" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.hub[0].name
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_postgres_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "spoke-postgres-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns_zone[0].name
  virtual_network_id    = module.spoke_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name
}


resource "azurerm_private_dns_zone_virtual_network_link" "secondary_postgres_spoke_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "secondary-spoke-postgres-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns_zone[0].name
  virtual_network_id    = module.secondary_spoke_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.spoke_postgres_virtual_network_link
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_postgres_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "hub-postgres-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres_dns_zone[0].name
  virtual_network_id    = module.hub_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.spoke_postgres_virtual_network_link,
    azurerm_private_dns_zone_virtual_network_link.secondary_postgres_spoke_virtual_network_link
  ]
}

###############################################
# privatelink.azconfig.io
###############################################
# Create Private DNS Zone and Endpoint for App Configuration

resource "azurerm_private_dns_zone" "dns_for_azconfig" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "privatelink.azconfig.io"
  resource_group_name = azurerm_resource_group.hub[0].name
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_azconfig_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "spoke-azconfig-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns_for_azconfig[0].name
  virtual_network_id    = module.spoke_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name
}


resource "azurerm_private_dns_zone_virtual_network_link" "secondary_azconfig_spoke_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "secondary-spoke-azconfig-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns_for_azconfig[0].name
  virtual_network_id    = module.secondary_spoke_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.spoke_azconfig_virtual_network_link
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_azconfig_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "hub-azconfig-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns_for_azconfig[0].name
  virtual_network_id    = module.hub_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.spoke_azconfig_virtual_network_link,
    azurerm_private_dns_zone_virtual_network_link.secondary_azconfig_spoke_virtual_network_link
  ]
}

resource "azurerm_private_endpoint" "primary_azconfig_pe" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "primary-private-endpoint-ac"
  location            = azurerm_resource_group.spoke[0].location
  resource_group_name = azurerm_resource_group.spoke[0].name
  subnet_id           = module.spoke_vnet[0].subnets[local.private_link_subnet_name].id

  private_dns_zone_group {
    name                 = "privatednsazconfigzonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_for_azconfig[0].id]
  }

  private_service_connection {
    name                           = "peconnection-azconfig"
    private_connection_resource_id = module.azconfig[0].azconfig_id
    is_manual_connection           = false
    subresource_names              = ["configurationStores"]
  }
}

resource "azurerm_private_endpoint" "secondary_azconfig_pe" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "secondaryprivate-endpoint-ac"
  location            = azurerm_resource_group.secondary_spoke[0].location
  resource_group_name = azurerm_resource_group.secondary_spoke[0].name
  subnet_id           = module.secondary_spoke_vnet[0].subnets[local.private_link_subnet_name].id

  private_dns_zone_group {
    name                 = "privatednsazconfigzonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_for_azconfig[0].id]
  }

  private_service_connection {
    name                           = "peconnection-azconfig"
    private_connection_resource_id = module.secondary_azconfig[0].azconfig_id
    is_manual_connection           = false
    subresource_names              = ["configurationStores"]
  }
}








###############################################
# privatelink.azurecr.io
###############################################

# Create Private DNS Zone and Endpoint for ACR

resource "azurerm_private_dns_zone" "dns_for_acr" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.hub[0].name
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke_azurecr_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "spoke-azurecr-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns_for_acr[0].name
  virtual_network_id    = module.spoke_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name
}


resource "azurerm_private_dns_zone_virtual_network_link" "secondary_azurecr_spoke_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "secondary-spoke-azurecr-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns_for_acr[0].name
  virtual_network_id    = module.secondary_spoke_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.spoke_azurecr_virtual_network_link
  ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_azurecr_virtual_network_link" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "hub-azurecr-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns_for_acr[0].name
  virtual_network_id    = module.hub_vnet[0].vnet_id
  resource_group_name   = azurerm_resource_group.hub[0].name

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.spoke_azurecr_virtual_network_link,
    azurerm_private_dns_zone_virtual_network_link.secondary_azurecr_spoke_virtual_network_link
  ]
}

resource "azurerm_private_endpoint" "acr_pe" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "private-endpoint-acr"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub[0].name
  subnet_id           = module.hub_vnet[0].subnets[local.private_link_subnet_name].id

  private_dns_zone_group {
    name                 = "privatednsacrzonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_for_acr[0].id]
  }

  private_service_connection {
    name                           = "peconnection-acr"
    private_connection_resource_id = module.acr[0].acr_id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}
