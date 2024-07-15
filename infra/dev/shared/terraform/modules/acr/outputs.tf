output "acr_name" {
  value       = azurerm_container_registry.acr.name
  description = "The Azure Container Registry Name."
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "The Azure Container Registry Login Server."
}

output "container_registry_user_assigned_identity_id" {
  value       = azurerm_user_assigned_identity.container_registry_user_assigned_identity.id
  description = "The ACR User Assigned Identity ID."

}