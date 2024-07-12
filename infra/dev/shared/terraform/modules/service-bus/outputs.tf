output "namespace_name" {
  value = azurerm_servicebus_namespace.servicebus_namespace.name
}

output "servicebus_namespace_primary_connection_string" {
  value = azurerm_servicebus_namespace.servicebus_namespace.default_primary_connection_string
}

output "queue_email_request_name" {
  value = azurerm_servicebus_queue.email_request_queue.name
}

output "queue_email_response_name" {
  value = azurerm_servicebus_queue.email_response_queue.name
}

