output "database_username" {
  value       = var.administrator_login
  description = "The DB server user name."
}

output "dev_database_server_id" {
  value       = azurerm_postgresql_flexible_server.dev_postresql_database.id
  description = "The id of the database server"
}

output "dev_database_fqdn" {
  value       = azurerm_postgresql_flexible_server.dev_postresql_database.fqdn
  description = "The FQDN of the database"
}
