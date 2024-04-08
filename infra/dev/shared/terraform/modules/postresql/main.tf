terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

resource "azurecaf_name" "dev_postgresql_server" {
  name          = var.application_name
  resource_type = "azurerm_postgresql_flexible_server"
  suffixes      = [var.location, var.environment]
}

resource "azurerm_postgresql_flexible_server" "dev_postresql_database" {
  name                          = azurecaf_name.dev_postgresql_server.result
  resource_group_name           = var.resource_group
  location                      = var.location
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  sku_name                      = var.sku_name
  version                       = "16"
  geo_redundant_backup_enabled  = false
  storage_mb                    = 32768
  zone                          = 1

  authentication {
      active_directory_auth_enabled  = true
      password_auth_enabled          = true
      tenant_id                      = var.azure_ad_tenant_id
  }

  tags = {
      "environment"      = var.environment
      "application-name" = var.application_name
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow-access-from-azure-services" {
  name             = "allow-access-from-azure-services"
  server_id        = azurerm_postgresql_flexible_server.dev_postresql_database.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
