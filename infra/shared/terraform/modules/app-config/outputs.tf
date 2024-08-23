output "azconfig_name" {
  value       = azurerm_app_configuration.app_config.name
  description = "The Azure App Configuration Name."
}
