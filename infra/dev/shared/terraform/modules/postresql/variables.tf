variable "resource_group" {
  type        = string
  description = "The resource group"
}

variable "azure_ad_tenant_id" {
  type        = string
  description = "The AD tenant id"
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

variable "administrator_login" {
  type        = string
  description = "The PostgreSQL administrator login"
  default     = "myadmin"
}

variable "administrator_password" {
  type        = string
  description = "The password for the PostgreSQL administrator login"
}

variable "sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}