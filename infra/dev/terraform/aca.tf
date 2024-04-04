resource "azurerm_container_app_environment" "container_app_environment" {
  name                       = var.application_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.dev.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.app_workspace.id
}

resource "azurerm_container_app" "container_app" {
  name                         = "email-processor"
  container_app_environment_id = azurerm_container_app_environment.container_app_environment.id
  resource_group_name          = azurerm_resource_group.dev.name
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
      azurerm_user_assigned_identity.container_registry_user_assigned_identity.id
    ]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.container_registry_user_assigned_identity.id
  }

  secret {
    name         = "azure-servicebus-connection-string"
    value        = azurerm_servicebus_namespace.servicebus_namespace.default_primary_connection_string
  }

  template {
    container {
      name   = "email-processor-app"

      // A container image is required to deploy the ACA resource.
      // Since the rendering service image is not available yet,
      // we use a placeholder image for now.
      image  = "mcr.microsoft.com/cbl-mariner/busybox:2.0"
      cpu    = 1.0
      memory = "2.0Gi"
      env {
        name  = "AZURE_SERVICEBUS_NAMESPACE"
        value = azurerm_servicebus_namespace.servicebus_namespace.name
      }
      env {
        name  = "AZURE_SERVICEBUS_EMAIL_REQUEST_QUEUE_NAME"
        value = azurerm_servicebus_queue.email_request_queue.name
      }
      env {
        name  = "AZURE_SERVICEBUS_EMAIL_RESPONSE_QUEUE_NAME"
        value = azurerm_servicebus_queue.email_response_queue.name
      }
    }
    max_replicas = 10
    min_replicas = 1

    custom_scale_rule {
      name = "service-bus-queue-length-rule"
      custom_rule_type = "azure-servicebus"
      metadata = {
        messageCount = 10
        namespace = azurerm_servicebus_namespace.servicebus_namespace.name
        queueName = azurerm_servicebus_queue.email_request_queue.name
      }
      authentication {
        secret_name = "azure-servicebus-connection-string"
        trigger_parameter = "connection"
      }
    }
  }
}
