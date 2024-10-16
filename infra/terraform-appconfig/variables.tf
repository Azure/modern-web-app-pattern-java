variable "primary_app_config_id" {
  type = string
}

variable "secondary_app_config_id" {
  type = string
}

variable "primary_app_config_keys" {
  type = list(object({
    key                 = string
    content_type        = optional(string)
    label               = optional(string)
    value               = optional(string)
    locked              = optional(bool)
    type                = optional(string, "kv")
    vault_key_reference = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for k in var.primary_app_config_keys :
      (k.type == "kv" && k.value != null) || (k.type == "vault" && k.vault_key_reference != null)
    ])
    error_message = "Type must be kv or vault. If vault, vault_key_reference must be set. If kv, value must be set."
  }

  description = "The keys to create in the App Configuration"
}

variable "seconday_app_config_keys" {
  type = list(object({
    key                 = string
    content_type        = optional(string)
    label               = optional(string)
    value               = optional(string)
    locked              = optional(bool)
    type                = optional(string, "kv")
    vault_key_reference = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for k in var.seconday_app_config_keys :
      (k.type == "kv" && k.value != null) || (k.type == "vault" && k.vault_key_reference != null)
    ])
    error_message = "Type must be kv or vault. If vault, vault_key_reference must be set. If kv, value must be set."
  }

  description = "The keys to create in the App Configuration"
}
