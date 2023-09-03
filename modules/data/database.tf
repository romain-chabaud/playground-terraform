resource "google_sql_database" "database" {
  name     = var.database_configuration.name
  instance = var.database_configuration.instance
}

resource "google_sql_user" "user" {
  name     = var.database_configuration.username
  instance = var.database_configuration.instance
  password = var.database_configuration.password
}