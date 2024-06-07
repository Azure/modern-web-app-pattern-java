resource "azurecaf_name" "servicebus_namespace_name" {
  name          = var.application_name
  resource_type = "azurerm_servicebus_namespace"
  suffixes      = ["dev"]
}

resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  name                = azurecaf_name.servicebus_namespace_name.result
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name
  sku                 = "Standard"

  # Should be set to false, but we need it for Keda scaling rules
  # https://github.com/microsoft/azure-container-apps/issues/592
  local_auth_enabled  = false

  zone_redundant      = false

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

######

resource "azurecaf_name" "servicebus_email_request_queue_name" {
  name          = "email-request-queue"
  resource_type = "azurerm_servicebus_queue"
  suffixes      = ["dev"]
}

resource "azurerm_servicebus_queue" "email_request_queue" {
  name = azurecaf_name.servicebus_email_request_queue_name.result
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id

  enable_partitioning   = false
  max_delivery_count    = 10
  lock_duration         = "PT30S"
  max_size_in_megabytes = 1024
  requires_session      = false
  default_message_ttl   = "P14D"
}

########################

resource "azurecaf_name" "servicebus_email_response_queue_name" {
  name          = "email-response-queue"
  resource_type = "azurerm_servicebus_queue"
  suffixes      = ["dev"]
}

resource "azurerm_servicebus_queue" "email_response_queue" {
  name = azurecaf_name.servicebus_email_response_queue_name.result
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id

  enable_partitioning   = false
  max_delivery_count    = 10
  lock_duration         = "PT30S"
  max_size_in_megabytes = 1024
  requires_session      = false
  default_message_ttl   = "P14D"
}


#######


resource "azurerm_role_assignment" "role_servicebus_data_owner" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = data.azuread_client_config.current.object_id
}

resource "azurerm_role_assignment" "role_servicebus_data_sender" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = module.dev_application.application_principal_id
}

resource "azurerm_role_assignment" "role_servicebus_data_receiver" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = module.dev_application.application_principal_id
}


######


resource "azurerm_role_assignment" "role_servicebus_data_sender_email_processor" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azurerm_container_app.container_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "role_servicebus_data_receiver_email_processor" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_container_app.container_app.identity[0].principal_id
}

