variable "secret_configuration" {
  type = object({
    name     = string
    location = string
    value    = string
  })
  sensitive = true
  nullable  = false
}