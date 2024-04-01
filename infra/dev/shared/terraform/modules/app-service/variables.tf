variable "resource_group" {
  type        = string
  description = "The resource group"
}

variable "application_name" {
  type        = string
  description = "The name of your application"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
}

variable "contoso_webapp_options" {
  type = object({
    contoso_active_directory_tenant_id      = string
    contoso_active_directory_client_id      = string
    contoso_active_directory_client_secret  = string

    postgresql_database_url       = string
    postgresql_database_user      = string
    postgresql_database_password  = string

    redis_host_name               = string
    redis_port                    = number
    redis_password                = string

    service_bus_namespace         = string
    service_bus_entity_name       = string
    service_bus_entity_type       = string
  })

  description = "The options for the webapp"
}
