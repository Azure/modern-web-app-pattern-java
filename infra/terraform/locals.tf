locals {

  #####################################
  # Shared Variables
  #####################################
  telemetryId = "92141f6a-c03e-4141-bc1c-2113e4772c8d-${var.location}"

  base_tags = {
    "terraform"        = true
    "environment"      = var.environment
    "application-name" = var.application_name
    "contoso-version"  = "1.0"
    "app-pattern-name" = "java-rwa"
    "azd-env-name"     = var.application_name
  }

  #####################################
  # Common
  #####################################
  private_link_subnet_name = "privateLink"

  #####################################
  # Hub Network Configuration Variables
  #####################################
  firewall_subnet_name = "AzureFirewallSubnet"
  bastion_subnet_name  = "AzureBastionSubnet"
  devops_subnet_name   = "devops"

  hub_vnet_cidr                = ["10.0.0.0/24"]
  firewall_subnet_cidr         = ["10.0.0.0/26"]
  bastion_subnet_cidr          = ["10.0.0.64/26"]
  devops_subnet_cidr           = ["10.0.0.128/26"]
  hub_private_link_subnet_cidr = ["10.0.0.192/26"]

  #####################################
  # Spoke Network Configuration Variables
  #####################################
  app_service_subnet_name = "serverFarm"
  ingress_subnet_name     = "ingress"
  postgresql_subnet_name  = "fs"

  spoke_vnet_cidr                = ["10.240.0.0/20"]
  appsvc_subnet_cidr             = ["10.240.0.0/26"]
  front_door_subnet_cidr         = ["10.240.0.64/26"]
  postgresql_subnet_cidr         = ["10.240.0.128/26"]
  spoke_private_link_subnet_cidr = ["10.240.11.0/24"]

  // Network cidrs for secondary region
  secondary_spoke_vnet_cidr                = ["10.241.0.0/20"]
  secondary_appsvc_subnet_cidr             = ["10.241.0.0/26"]
  secondary_front_door_subnet_cidr         = ["10.241.0.64/26"]
  secondary_postgresql_subnet_cidr         = ["10.241.0.128/26"]
  secondary_spoke_private_link_subnet_cidr = ["10.241.11.0/24"]

  #####################################
  # Application Configuration Variables
  #####################################
  front_door_sku_name = var.environment == "prod" ? "Premium_AzureFrontDoor" : "Standard_AzureFrontDoor"
  postgresql_sku_name = var.environment == "prod" ? "GP_Standard_D4s_v3" : "B_Standard_B1ms"

  dev_azconfig_key_mapping = {
    "dev-contoso-database-url"            = "/contoso-fiber/spring.datasource.url"
    "dev-contoso-database-admin"          = "/contoso-fiber/spring.datasource.username"
    "dev-contoso-database-admin-password" = "/contoso-fiber/spring.datasource.password"
    "dev-contoso-servicebus-namespace"    = "/contoso-fiber/spring.cloud.azure.servicebus.namespace"
    "dev-contoso-email-request-queue"     = "/contoso-fiber/spring.cloud.stream.bindings.produceemailrequest-out-0.destination"
    "dev-contoso-email-response-queue"    = "/contoso-fiber/spring.cloud.stream.bindings.consumeemailresponse-in-0.destination"
    "dev-contoso-storage-account"         = "/contoso-fiber/spring.cloud.azure.storage.blob.account-name"
    "dev-contoso-storage-container-name"  = "/contoso-fiber/spring.cloud.azure.storage.blob.container-name"
    "dev-contoso-redis-password"          = "/contoso-fiber/spring.data.redis.password"
  }

  # Create a map that explicitly ties Key Vault secret names to App Config key paths
  dev_secret_to_azconfig_mapping = {
    for k, v in module.dev_secrets[0].secret_names : k => {
      key                 = local.dev_azconfig_key_mapping[k]
      vault_key_reference = v
    }
  }

  # Create the azconfig_keys array from the transformed map
  dev_azconfig_secret_keys = [
    for k, v in local.dev_secret_to_azconfig_mapping : {
      key                 = v.key
      vault_key_reference = v.vault_key_reference
      type                = "vault"
    }
  ]

  dev_azconfig_non_secret_keys = [
    {
      key                 = "/contoso-fiber/spring.cloud.azure.active-directory.profile.tenant-id"
      vault_key_reference = azurerm_key_vault_secret.dev_contoso_application_tenant_id[0].id
      type                = "vault"
    },
    {
      key                 = "/contoso-fiber/spring.cloud.azure.active-directory.credential.client-id"
      vault_key_reference = azurerm_key_vault_secret.dev_contoso_application_client_id[0].id
      type                = "vault"
    },
    {
      key                 = "/contoso-fiber/spring.cloud.azure.active-directory.credential.client-secret"
      vault_key_reference = azurerm_key_vault_secret.dev_contoso_application_client_secret[0].id
      type                = "vault"
    },
    {
      key   = "/contoso-fiber/spring.data.redis.host"
      value = module.dev_cache[0].cache_hostname
      type  = "kv"
    },
    {
      key   = "/contoso-fiber/spring.data.redis.port"
      value = module.dev_cache[0].cache_ssl_port
      type  = "kv"
    }
  ]

  dev_azconfig_keys = concat(local.dev_azconfig_secret_keys, local.dev_azconfig_non_secret_keys)
}

