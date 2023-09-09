variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "db_instance_authorized_networks" {
  type    = string
  default = "0.0.0.0/0"
}

variable "voting_db_password_length" {
  type = number
}

variable "petclinic_db_password_length" {
  type = number
}

variable "min_db_password_length" {
  type    = number
  default = 8
}