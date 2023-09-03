variable "secret_configuration" {
  type = object({
    name     = string
    location = string
    value    = string
  })
  sensitive = true
  nullable  = false
}

variable "secret_manager_service_account" {
  type      = string
  sensitive = true
  nullable  = false
}