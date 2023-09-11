variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "database_instance_name" {
  type    = string
  default = "shared-database-instance"
}

variable "voting_database_desired_password_length" {
  type = number
}

variable "petclinic_database_desired_password_length" {
  type = number
}