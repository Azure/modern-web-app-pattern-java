# ---------------------------
#  Dev - Resource Group Name
# ---------------------------

output "dev_resource_group" {
  value = azurerm_resource_group.dev.name
  description = "The Dev Resource Group Name."
}

output "app_service_name" {
  value = module.dev_application.application_name
  description = "The App Service Name."
}

output "application_url" {
  value       = "https://${module.dev_application.application_fqdn}"
  description = "The URL of the application."
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
  description = "The Azure Container Registry Name."
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
  description = "The Azure Container Registry Login Server."
}

output "AZURE_CONTAINER_REGISTRY_ENDPOINT" {
  value = azurerm_container_registry.acr.login_server
  description = "The Azure Container Registry Endpoint."
}
