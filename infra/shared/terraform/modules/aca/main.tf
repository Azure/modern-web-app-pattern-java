terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

# Container Apps environment naming convention using azurecaf_name module.
resource "azurecaf_name" "container_app_environment_name" {
  name          = var.application_name
  resource_type = "azurerm_container_app_environment"
  suffixes      = [var.environment]
}

# Create Azure Container Apps Environment in Dev

resource "azurerm_container_app_environment" "container_app_environment_dev" {
  count                      = var.environment == "dev" ? 1 : 0
  name                        = azurecaf_name.container_app_environment_name.result
  location                   = var.location
  resource_group_name        = var.resource_group
  log_analytics_workspace_id = var.log_analytics_workspace_id

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

# Create Azure Container Apps Environment in Prod

resource "azurerm_container_app_environment" "container_app_environment_prod" {
  count                      = var.environment == "prod" ? 1 : 0
  name                        = azurecaf_name.container_app_environment_name.result
  location                   = var.location
  resource_group_name        = var.resource_group
  log_analytics_workspace_id = var.log_analytics_workspace_id
  zone_redundancy_enabled    = true

  internal_load_balancer_enabled = var.isNetworkIsolated
  infrastructure_subnet_id       = var.infrastructure_subnet_id

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

# Create Azure Container App in the specified environment

resource "azurerm_container_app" "container_app" {
  name                         = "email-processor"
  container_app_environment_id = var.environment == "dev" ? azurerm_container_app_environment.container_app_environment_dev[0].id : azurerm_container_app_environment.container_app_environment_prod[0].id
  resource_group_name          = var.resource_group
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
    "azd-service-name" = "email-processor"
  }

  lifecycle {
    ignore_changes = [
      template.0.container["image"]
    ]
  }

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      var.container_registry_user_assigned_identity_id
    ]
  }

  registry {
    server   = var.acr_login_server
    identity = var.container_registry_user_assigned_identity_id
  }

  secret {
    name  = "azure-servicebus-connection-string"
    value = var.servicebus_namespace_primary_connection_string
  }

  template {
    container {
      name = "email-processor-app"

      // A container image is required to deploy the ACA resource.
      // Since the rendering service image is not available yet,
      // we use a placeholder image for now.
      image  = "mcr.microsoft.com/cbl-mariner/busybox:2.0"
      cpu    = 1.0
      memory = "2.0Gi"
      env {
        name  = "AZURE_SERVICEBUS_NAMESPACE"
        value = var.servicebus_namespace
      }
      env {
        name  = "AZURE_SERVICEBUS_EMAIL_REQUEST_QUEUE_NAME"
        value = var.email_request_queue_name
      }
      env {
        name  = "AZURE_SERVICEBUS_EMAIL_RESPONSE_QUEUE_NAME"
        value = var.email_response_queue_name
      }
    }
    max_replicas = 10
    min_replicas = 1

    custom_scale_rule {
      name             = "service-bus-queue-length-rule"
      custom_rule_type = "azure-servicebus"
      metadata = {
        messageCount = 10
        namespace    = var.servicebus_namespace
        queueName    = var.email_request_queue_name
      }
      authentication {
        secret_name       = "azure-servicebus-connection-string"
        trigger_parameter = "connection"
      }
    }
  }
}

# Create Private DNS Zone for Azure Container Apps in Prod if internal load balancer is enabled

resource "azurerm_private_dns_zone" "dns_for_aca" {
  count               = var.environment == "prod" && var.isNetworkIsolated ? 1 : 0
  name                = var.environment == "prod" ? azurerm_container_app_environment.container_app_environment_prod[0].default_domain : azurerm_container_app_environment.container_app_environment_dev[0].default_domain
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "virtual_network_link_aca" {
  count                 = var.environment == "prod" && var.isNetworkIsolated ? 1 : 0
  name                  = "privatelink.azurecr.io"
  private_dns_zone_name = azurerm_private_dns_zone.dns_for_aca[0].name
  virtual_network_id    = var.spoke_vnet_id
  resource_group_name   = var.resource_group
}