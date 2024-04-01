# Generate password if none provided
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  database_administrator_password = coalesce(var.database_administrator_password, random_password.password.result)
}

module "dev_postresql_database" {
  source                      = "../shared/terraform/modules/postresql"
  azure_ad_tenant_id          = data.azuread_client_config.current.tenant_id
  resource_group              = azurerm_resource_group.dev.name
  application_name            = var.application_name
  environment                 = var.environment
  location                    = var.location
  administrator_password      = local.database_administrator_password
  sku_name                    = local.postgresql_sku_name
}

resource "azurerm_postgresql_flexible_server_database" "dev_postresql_database_db" {
  name      = "${var.application_name}db"
  server_id = module.dev_postresql_database.dev_database_server_id
}
