terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}

data "azuread_client_config" "current" {}

resource "azurecaf_name" "servicebus_namespace_name" {
  name          = var.application_name
  resource_type = "azurerm_servicebus_namespace"
  suffixes      = [var.location, var.environment]
}

# Create Service Bus namespace

resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  name                          = azurecaf_name.servicebus_namespace_name.result
  location                      = var.location
  resource_group_name           = var.resource_group
  sku                           = var.environment == "prod" ? "Premium" : "Standard"
  public_network_access_enabled = var.environment == "prod" ? false : true
  capacity                      = var.environment == "prod" ? var.capacity : 0
  premium_messaging_partitions  = var.environment == "prod" ? 1 : 0
  # Should be set to false, but we need it for Keda scaling rules
  # https://github.com/hashicorp/terraform-provider-azurerm/issues/26570
  local_auth_enabled = true

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

# Create Email Request queue

resource "azurecaf_name" "servicebus_email_request_queue_name" {
  name          = "email-request-queue"
  resource_type = "azurerm_servicebus_queue"
  suffixes      = [var.environment]
}

resource "azurerm_servicebus_queue" "email_request_queue" {
  name         = azurecaf_name.servicebus_email_request_queue_name.result
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id

  partitioning_enabled = false
  max_delivery_count    = 10
  lock_duration         = "PT30S"
  max_size_in_megabytes = 1024
  requires_session      = false
  default_message_ttl   = "P14D"
}

# Create Email Response queue

resource "azurecaf_name" "servicebus_email_response_queue_name" {
  name          = "email-response-queue"
  resource_type = "azurerm_servicebus_queue"
  suffixes      = [var.environment]
}

resource "azurerm_servicebus_queue" "email_response_queue" {
  name         = azurecaf_name.servicebus_email_response_queue_name.result
  namespace_id = azurerm_servicebus_namespace.servicebus_namespace.id

  partitioning_enabled   = false
  max_delivery_count    = 10
  lock_duration         = "PT30S"
  max_size_in_megabytes = 1024
  requires_session      = false
  default_message_ttl   = "P14D"
}


# Create role assignments

resource "azurerm_role_assignment" "role_servicebus_data_owner" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = data.azuread_client_config.current.object_id
}

resource "azurerm_role_assignment" "role_servicebus_data_sender" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = var.web_application_principal_id
}

resource "azurerm_role_assignment" "role_servicebus_data_receiver" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = var.web_application_principal_id
}


######


resource "azurerm_role_assignment" "role_servicebus_data_sender_email_processor" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = var.container_app_identity_principal_id
}

resource "azurerm_role_assignment" "role_servicebus_data_receiver_email_processor" {
  scope                = azurerm_servicebus_namespace.servicebus_namespace.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = var.container_app_identity_principal_id
}

# Create Private DNS Zone and Endpoint for Service Bus

resource "azurerm_private_dns_zone" "dns_for_service_bus" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "virtual_network_link_service_bus" {
  count                 = var.environment == "prod" ? 1 : 0
  name                  = "privatelink.servicebus.windows.net"
  private_dns_zone_name = azurerm_private_dns_zone.dns_for_service_bus[0].name
  virtual_network_id    = var.spoke_vnet_id
  resource_group_name   = var.resource_group
}

resource "azurerm_private_endpoint" "service_bus_pe" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "private-endpoint-service-bus"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "privatednsservicebuszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_for_service_bus[0].id]
  }

  private_service_connection {
    name                           = "peconnection-service-bus"
    private_connection_resource_id = azurerm_servicebus_namespace.servicebus_namespace.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }
}
