terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

resource "azurerm_container_app_environment" "container_app_environment" {
  name                       = var.application_name
  location                   = var.location
  resource_group_name        = var.resource_group
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_container_app" "container_app" {
  name                         = "email-processor"
  container_app_environment_id = azurerm_container_app_environment.container_app_environment.id
  resource_group_name          = var.resource_group
  revision_mode                = "Single"

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
