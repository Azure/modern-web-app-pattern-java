locals {

  #####################################
  # Shared Variables
  #####################################
  telemetryId = "bd71b215-474b-4d90-b2d9-c1d2eb9245d1-${var.location}"

  base_tags = {
    "terraform"        = true
    "environment"      = var.environment
    "application-name" = var.application_name
    "contoso-version"  = "1.0"
    "app-pattern-name" = "java-mwa"
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
  aca_subnet_name = "aca"

  spoke_vnet_cidr                = ["10.240.0.0/20"]
  subnetPrefixes = [ for i in range(0, 16): cidrsubnet("10.240.0.0/20", 6, i)]

#   appsvc_subnet_cidr             = ["10.240.0.0/26"]
#   front_door_subnet_cidr         = ["10.240.0.64/26"]
#   postgresql_subnet_cidr         = ["10.240.0.128/26"]
#   spoke_private_link_subnet_cidr = ["10.240.11.0/24"]
#   spoke_aca_subnet_cidr          = ["10.240.11.0/24"]

  // Network cidrs for secondary region
  secondary_spoke_vnet_cidr                = ["10.241.0.0/20"]
  secondary_subnetPrefixes = [ for i in range(0, 16): cidrsubnet("10.241.0.0/20", 6, i)]
#   secondary_appsvc_subnet_cidr             = ["10.241.0.0/26"]
#   secondary_front_door_subnet_cidr         = ["10.241.0.64/26"]
#   secondary_postgresql_subnet_cidr         = ["10.241.0.128/26"]
#   secondary_spoke_private_link_subnet_cidr = ["10.241.11.0/24"]
#   secondary_spoke_aca_subnet_cidr          = ["10.241.11.0/24"]

  #####################################
  # Application Configuration Variables
  #####################################
  front_door_sku_name = var.environment == "prod" ? "Premium_AzureFrontDoor" : "Standard_AzureFrontDoor"
  postgresql_sku_name = var.environment == "prod" ? "GP_Standard_D4s_v3" : "B_Standard_B1ms"

  #####################################
  # Storage account configuration variables
  #####################################
  account_replication_type = var.environment == "prod" ? "GZRS" : "ZRS"

  azconfig_key_mapping = {
    "contoso-application-tenant-id"      = "/contoso-fiber/AZURE_ACTIVE_DIRECTORY_TENANT_ID"
    "contoso-application-client-id"      = "/contoso-fiber/AZURE_ACTIVE_DIRECTORY_CREDENTIAL_CLIENT_ID"
    "contoso-application-client-secret"  = "/contoso-fiber/AZURE_ACTIVE_DIRECTORY_CREDENTIAL_CLIENT_SECRET"
    "contoso-redis-password"             = "/contoso-fiber/REDIS_PASSWORD"
  }

  # Create a map that explicitly ties Key Vault secret names to App Config key paths

  dev_secret_to_azconfig_mapping = var.environment == "dev" ? {
    for k, v in local.azconfig_key_mapping : k => {
      key                 = v
      vault_key_reference = module.dev_secrets[0].secret_names[k]
    }
  }: null

   primary_secret_to_azconfig_mapping = var.environment == "prod" ?{
    for k, v in local.azconfig_key_mapping : k => {
      key                 = v
      vault_key_reference = module.secrets[0].secret_names[k]
    }
  }: null

  # Create the azconfig_keys array from the transformed map
  dev_azconfig_secret_keys = var.environment == "dev" ?[
    for k, v in local.dev_secret_to_azconfig_mapping : {
      key                 = v.key
      vault_key_reference = v.vault_key_reference
      type                = "vault"
    }
  ]: null

  prod_azconfig_secret_keys = var.environment == "prod" ? [
    for k, v in local.primary_secret_to_azconfig_mapping : {
      key                 = v.key
      vault_key_reference = v.vault_key_reference
      type                = "vault"
    }
  ]: null

  azconfig_common_keys = [
    {
      key   = "/contoso-fiber/CONTOSO_RETRY_DEMO"
      value = "0"
      type  = "kv"
    },
    {
      key   = "/contoso-fiber/CONTOSO_SUPPORT_GUIDE_REQUEST_SERVICE"
      value = "queue"
      type  = "kv"
    }
  ]

  dev_azconfig_non_secret_keys = var.environment == "dev"? [
    {
      key = "/contoso-fiber/AZURE_SERVICEBUS_NAMESPACE"
      value = module.dev_servicebus[0].namespace_name
      type = "kv"
    },
    {
      key   = "/contoso-fiber/REDIS_HOST"
      value = module.dev_cache[0].cache_hostname
      type  = "kv"
    },
    {
      key   = "/contoso-fiber/REDIS_PORT"
      value = module.dev_cache[0].cache_ssl_port
      type  = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_SERVICEBUS_EMAIL_REQUEST_QUEUE_NAME"
      value = module.dev_servicebus[0].queue_email_request_name
      type = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_SERVICEBUS_EMAIL_RESPONSE_QUEUE_NAME"
      value = module.dev_servicebus[0].queue_email_response_name
      type = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_STORAGE_ACCOUNT_NAME"
      value = module.dev_storage[0].storage_account_name
      type = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_STORAGE_CONTAINER_NAME"
      value = module.dev_storage[0].storage_container_name
      type = "kv"
    }
  ]: null

  primary_azconfig_non_secret_keys = var.environment == "prod" ?[
    {
      key = "/contoso-fiber/AZURE_SERVICEBUS_NAMESPACE"
      value = module.servicebus[0].namespace_name
      type = "kv"
    },
    {
      key   = "/contoso-fiber/REDIS_HOST"
      value = module.cache[0].cache_hostname
      type  = "kv"
    },
    {
      key   = "/contoso-fiber/REDIS_PORT"
      value = module.cache[0].cache_ssl_port
      type  = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_SERVICEBUS_EMAIL_REQUEST_QUEUE_NAME"
      value = module.servicebus[0].queue_email_request_name
      type = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_SERVICEBUS_EMAIL_RESPONSE_QUEUE_NAME"
      value = module.servicebus[0].queue_email_response_name
      type = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_STORAGE_ACCOUNT_NAME"
      value = module.storage[0].storage_account_name
      type = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_STORAGE_CONTAINER_NAME"
      value = module.storage[0].storage_container_name
      type = "kv"
    }

  ]: null

  secondary_azconfig_non_secret_keys = var.environment == "prod" ?[
    {
      key = "/contoso-fiber/AZURE_SERVICEBUS_NAMESPACE"
      value = module.secondary_servicebus[0].namespace_name
      type = "kv"
    },
    {
      key   = "/contoso-fiber/REDIS_HOST"
      value = module.secondary_cache[0].cache_hostname
      type  = "kv"
    },
    {
      key   = "/contoso-fiber/REDIS_PORT"
      value = module.secondary_cache[0].cache_ssl_port
      type  = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_SERVICEBUS_EMAIL_REQUEST_QUEUE_NAME"
      value = module.secondary_servicebus[0].queue_email_request_name
      type = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_SERVICEBUS_EMAIL_RESPONSE_QUEUE_NAME"
      value = module.secondary_servicebus[0].queue_email_response_name
      type = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_STORAGE_ACCOUNT_NAME"
      value = module.storage[0].storage_account_name
      type = "kv"
    },
    {
      key = "/contoso-fiber/AZURE_STORAGE_CONTAINER_NAME"
      value = module.storage[0].storage_container_name
      type = "kv"
    }

  ]: null

  dev_azconfig_keys = var.environment == "dev" ? concat(local.dev_azconfig_secret_keys, local.dev_azconfig_non_secret_keys, local.azconfig_common_keys): null
  primary_azconfig_keys = var.environment == "prod" ? concat(local.prod_azconfig_secret_keys, local.primary_azconfig_non_secret_keys, local.azconfig_common_keys): null
  secondary_azconfig_keys = var.environment == "prod" ? concat(local.prod_azconfig_secret_keys, local.secondary_azconfig_non_secret_keys, local.azconfig_common_keys): null
}

