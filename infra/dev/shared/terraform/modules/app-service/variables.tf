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

variable "service_management_reference" {
  type = string
  description = "value for the service management reference"
  default = null
}

variable "contoso_webapp_options" {
  type = object({
    active_directory_tenant_id      = string
    active_directory_client_id      = string
    active_directory_client_secret  = string

    postgresql_database_url       = string
    postgresql_database_user      = string
    postgresql_database_password  = string

    redis_host_name               = string
    redis_port                    = number
    redis_password                = string

    service_bus_namespace               = string
    service_bus_email_request_queue     = string
    service_bus_email_response_queue    = string
  })

  description = "The options for the webapp"
}
