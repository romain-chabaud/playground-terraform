resource "google_sql_database_instance" "shared_database_instance" {
  name             = "shared-db-instance"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"
  }
}

# voting database
resource "google_sql_database" "voting_database" {
  name     = "voting_db"
  instance = google_sql_database_instance.shared_database_instance.name
}

resource "random_password" "generated_voting_database_password" {
  length = var.voting_db_password_length >= var.min_db_password_length ? var.voting_db_password_length : var.min_db_password_length
}

resource "google_sql_user" "voting_database_user" {
  name     = "voting-db-user"
  instance = google_sql_database_instance.shared_database_instance.name
  password = random_password.generated_voting_database_password.result
}

# petclinic database
resource "google_sql_database" "petclinic_database" {
  name     = "petclinic"
  instance = google_sql_database_instance.shared_database_instance.name
}

resource "random_password" "generated_petclinic_database_password" {
  length = var.petclinic_db_password_length >= var.min_db_password_length ? var.petclinic_db_password_length : var.min_db_password_length
}

resource "google_sql_user" "petclinic_database_user" {
  name     = "petclinic-db-user"
  instance = google_sql_database_instance.shared_database_instance.name
  password = random_password.generated_petclinic_database_password.result
}