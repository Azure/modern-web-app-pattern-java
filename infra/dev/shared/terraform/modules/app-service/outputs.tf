output "application_fqdn" {
  value       = azurerm_linux_web_app.application.default_hostname
  description = "The Web application fully qualified domain name (FQDN)."
}

output "web_app_id" {
  value       = azurerm_linux_web_app.application.id
  description = "The ID of the web app."
}

output "application_principal_id" {
  value       = azurerm_linux_web_app.application.identity[0].principal_id
  description = "The id of system assigned managed identity"
}

output "application_name" {
  value       = azurerm_linux_web_app.application.name
  description = "The name for this Linux Web App"
}

output "application_registration_id" {
  value = azuread_application.app_registration.application_id
  description = "The id of application registration  (also called Client ID)."
}

output "application_client_secret" {
  value       = azuread_application_password.application_password.value
  sensitive   = true
  description = "The client secret of the application"
}
