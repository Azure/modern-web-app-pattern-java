provider "azurerm" {
  # by default teraform uses the shared access key to access the storage account.
  # to have terraform, use azure ad instead, set this property to true
  storage_use_azuread = true

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = true
    }
  }
}

resource "azurecaf_name" "dev_resource_group" {
  name          = var.application_name
  resource_type = "azurerm_resource_group"
  suffixes      = ["dev"]
}

resource "azurerm_resource_group" "dev" {
  name     = azurecaf_name.dev_resource_group.result
  location = var.location
  tags     = local.base_tags
}
