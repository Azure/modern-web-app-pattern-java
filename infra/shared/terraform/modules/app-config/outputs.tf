output "azconfig_name" {
  value       = azurerm_app_configuration.app_config.name
  description = "The Azure App Configuration Name."
}

output "azconfig_uri" {
  value       = azurerm_app_configuration.app_config.endpoint
  description = "The Azure App Configuration URI."
}

output "azconfig_id" {
  value       = azurerm_app_configuration.app_config.id
  description = "The Azure App Configuration ID."
}