# voting database
resource "google_sql_database_instance" "voting_database_instance" {
  name             = "voting-db-instance"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "voting_database" {
  name     = "voting_db"
  instance = google_sql_database_instance.voting_database_instance.name
}

resource "google_sql_user" "voting_database_user" {
  name     = "voting-db-user"
  instance = google_sql_database_instance.voting_database_instance.name
  password = google_secret_manager_secret_version.voting_database_password_secret_value.secret_data
}