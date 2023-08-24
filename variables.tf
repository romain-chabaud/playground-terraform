variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "voting_db_password_length" {
  type = number
}

variable "min_db_password_length" {
  type    = number
  default = 8
}