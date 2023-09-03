variable "database_configuration" {
  type = object({
    instance = string
    name     = string
    username = string
    password = string
  })
  sensitive = true
  nullable  = false
}