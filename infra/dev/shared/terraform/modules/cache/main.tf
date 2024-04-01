terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

resource "azurecaf_name" "cache" {
  random_length = "15"
  resource_type = "azurerm_redis_cache"
  suffixes      = [var.environment]
}

resource "azurerm_redis_cache" "cache" {
  name                = azurecaf_name.cache.result
  location            = var.location
  resource_group_name = var.resource_group
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  minimum_tls_version = "1.2"
  # public network access will be allowed for non-prod so devs can do integration testing while debugging locally
  public_network_access_enabled = true

  # https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-configure#default-redis-server-configuration
  redis_configuration {
  }
}
