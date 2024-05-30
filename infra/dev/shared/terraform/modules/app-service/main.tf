terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.26"
    }
  }
}


data "azuread_client_config" "current" {}

resource "azurecaf_name" "app_service" {
  name          = var.application_name
  resource_type = "azurerm_app_service"
  suffixes      = [var.environment]
}

resource "random_uuid" "account_manager_role_id" {}
resource "random_uuid" "l1_role_id" {}
resource "random_uuid" "l2_role_id" {}
resource "random_uuid" "field_service_role_id" {}
resource "random_uuid" "business_owner_role_id" {}

resource "azuread_application" "app_registration" {
  display_name     = "${azurecaf_name.app_service.result}-app"
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"  # single tenant

  app_role {
    allowed_member_types = ["User"]
    description          = "Account Managers"
    display_name         = "Account Manager"
    enabled              = true
    id                   = random_uuid.account_manager_role_id.result
    value                = "AccountManager"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "L1 Support representative"
    display_name         = "L1 Support"
    enabled              = true
    id                   = random_uuid.l1_role_id.result
    value                = "L1Support"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "L2 Support representative"
    display_name         = "L2 Support"
    enabled              = true
    id                   = random_uuid.l2_role_id.result
    value                = "L2Support"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Field Service representative"
    display_name         = "Field Service"
    enabled              = true
    id                   = random_uuid.field_service_role_id.result
    value                = "FieldService"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Business owner"
    display_name         = "Business Owner"
    enabled              = true
    id                   = random_uuid.business_owner_role_id.result
    value                = "BusinessOwner"
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read https://marketplace.visualstudio.com/items?itemName=stephane-eyskens.aadv1appprovisioning
      type = "Scope"
    }
  }

  web {
    homepage_url  = "https://${azurecaf_name.app_service.result}"
    logout_url    = "https://${azurecaf_name.app_service.result}/logout"
    redirect_uris = ["https://${azurecaf_name.app_service.result}.azurewebsites.net/login/oauth2/code/", "https://localhost:8080/login/oauth2/code/", "http://localhost:8080/login/oauth2/code/"]
    implicit_grant {
      id_token_issuance_enabled     = true
    }
  }

  service_management_reference = var.service_management_reference
}

resource "azuread_service_principal" "application_service_principal" {
  client_id = azuread_application.app_registration.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "application_password" {
  application_id = azuread_application.app_registration.id
  end_date_relative = "4320h"
}

# This is not guidance and is done for demo purposes. The resource below will add the
# "L1Support", "AccountManager", and "BusinessOwner" app role assignment for the application
# of the current user deploying this sample.
resource "azuread_app_role_assignment" "application_role_current_user" {
  app_role_id         = azuread_service_principal.application_service_principal.app_role_ids["AccountManager"]
  principal_object_id = data.azuread_client_config.current.object_id
  resource_object_id  = azuread_service_principal.application_service_principal.object_id
}

resource "azuread_app_role_assignment" "application_role_current_user_l1" {
  app_role_id         = azuread_service_principal.application_service_principal.app_role_ids["L1Support"]
  principal_object_id = data.azuread_client_config.current.object_id
  resource_object_id  = azuread_service_principal.application_service_principal.object_id
}

resource "azuread_app_role_assignment" "application_role_current_user_business_owner" {
  app_role_id         = azuread_service_principal.application_service_principal.app_role_ids["BusinessOwner"]
  principal_object_id = data.azuread_client_config.current.object_id
  resource_object_id  = azuread_service_principal.application_service_principal.object_id
}


resource "azurecaf_name" "app_service_plan" {
  name          = var.application_name
  resource_type = "azurerm_app_service_plan"
  suffixes      = [var.location, var.environment]
}

# This creates the plan that the service use
resource "azurerm_service_plan" "application" {
  name                         = azurecaf_name.app_service_plan.result
  resource_group_name          = var.resource_group
  location                     = var.location

  sku_name = var.environment == "prod" ? "P2v3" : "P1v3"
  os_type  = "Linux"

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
  }
}

# This creates the linux web app
resource "azurerm_linux_web_app" "application" {
  name                    = azurecaf_name.app_service.result
  location                = var.location
  resource_group_name     = var.resource_group
  service_plan_id         = azurerm_service_plan.application.id
  client_affinity_enabled = false
  https_only              = true

  identity {
    type = "SystemAssigned"
  }

  tags = {
    "environment"      = var.environment
    "application-name" = var.application_name
    "azd-service-name" = "application"
  }

  site_config {
    use_32_bit_worker      = false

    ftps_state              = "Disabled"
    minimum_tls_version     = "1.2"
    always_on               = true
    health_check_path       = "/actuator/health"

    application_stack {
      java_server = "JAVA"
      java_server_version = "17"
      java_version = "17"
    }
  }

  app_settings = {
    DATABASE_URL      = var.contoso_webapp_options.postgresql_database_url
    DATABASE_USERNAME = var.contoso_webapp_options.postgresql_database_user
    DATABASE_PASSWORD = var.contoso_webapp_options.postgresql_database_password

    AZURE_ACTIVE_DIRECTORY_CREDENTIAL_CLIENT_ID     = var.contoso_webapp_options.active_directory_client_id
    AZURE_ACTIVE_DIRECTORY_CREDENTIAL_CLIENT_SECRET = var.contoso_webapp_options.active_directory_client_secret
    AZURE_ACTIVE_DIRECTORY_TENANT_ID                = var.contoso_webapp_options.active_directory_tenant_id

    REDIS_HOST = var.contoso_webapp_options.redis_host_name
    REDIS_PORT = var.contoso_webapp_options.redis_port
    REDIS_PASSWORD = var.contoso_webapp_options.redis_password

    AZURE_SERVICEBUS_NAMESPACE                  = var.contoso_webapp_options.service_bus_namespace
    AZURE_SERVICEBUS_EMAIL_REQUEST_QUEUE_NAME   = var.contoso_webapp_options.service_bus_email_request_queue
    AZURE_SERVICEBUS_EMAIL_RESPONSE_QUEUE_NAME  = var.contoso_webapp_options.service_bus_email_response_queue

    CONTOSO_RETRY_DEMO = "0"

    CONTOSO_SUPPORT_GUIDE_REQUEST_SERVICE="email"
  }

  logs {
    http_logs {
      file_system {
        retention_in_mb   = 35
        retention_in_days = 30
      }
    }
  }
}
