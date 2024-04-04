# Log Analiytics Workspace
resource "azurecaf_name" "app_workspace" {
  name          = var.application_name
  resource_type = "azurerm_log_analytics_workspace"
  suffixes      = [var.environment]
}

resource "azurerm_log_analytics_workspace" "app_workspace" {
  name                = azurecaf_name.app_workspace.result
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Application Insight
resource "azurecaf_name" "app_insights" {
  name          = var.application_name
  resource_type = "azurerm_application_insights"
  suffixes      = [var.environment]
}

resource "azurerm_application_insights" "app_insights" {
  name                = azurecaf_name.app_insights.result
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name
  application_type    = "java"
  workspace_id        = azurerm_log_analytics_workspace.app_workspace.id
}