terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

data "azuread_client_config" "current" {}

resource "azurecaf_name" "app_storage" {
  name          = var.application_name
  resource_type = "azurerm_storage_account"
  suffixes      = [var.environment]
}

resource "azurerm_storage_account" "sa" {
  name                     = azurecaf_name.app_storage.result
  resource_group_name      = var.resource_group
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  shared_access_key_enabled = false

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account_network_rules" "cams-storage-network-rules" {
  storage_account_id = azurerm_storage_account.sa.id

  default_action             = "Allow"
  ip_rules                   = var.ip_rules
  bypass                     = ["AzureServices"]
}

resource "azurerm_role_assignment" "storage_account_contributor" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azuread_client_config.current.object_id
}

resource "azurerm_role_assignment" "storage_blob_data_owner" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azuread_client_config.current.object_id
}

resource "azurerm_role_assignment" "storage_container_app_data_contributor" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.principal_id
}

resource "azurerm_role_assignment" "app_storage_blob_data_owner" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = var.principal_id
}

resource "azurecaf_name" "app_storage_container" {
  name          = "supportguides"
  resource_type = "azurerm_storage_container"
  suffixes      = [var.environment]
}

resource "azurerm_storage_container" "container" {
  name                  = azurecaf_name.app_storage_container.result
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "container"

  depends_on = [ azurerm_role_assignment.storage_account_contributor ]
}
