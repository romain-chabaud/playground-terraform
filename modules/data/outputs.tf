output "database_name" {
  value = google_sql_database.database.name
}

output "database_user" {
  value = google_sql_user.user.name
}

output "database_password" {
  value = google_sql_user.user.password
}