resource "google_sql_database_instance" "shared_database_instance" {
  name             = "shared-db-instance"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"
  }
}
# voting database
resource "random_password" "generated_voting_database_password" {
  length = var.voting_db_password_length >= var.min_db_password_length ? var.voting_db_password_length : var.min_db_password_length
}

module "voting_data" {
  source = "./modules/data"
  database_configuration = {
    instance = google_sql_database_instance.shared_database_instance.name
    name     = "voting_db"
    username = "voting-db-user"
    password = random_password.generated_voting_database_password.result
  }
}

moved {
  from = google_sql_database.voting_database
  to   = module.voting_data.google_sql_database.database
}

moved {
  from = google_sql_user.voting_database_user
  to   = module.voting_data.google_sql_user.user
}

# petclinic database
resource "random_password" "generated_petclinic_database_password" {
  length = var.petclinic_db_password_length >= var.min_db_password_length ? var.petclinic_db_password_length : var.min_db_password_length
}

module "petclinic_data" {
  source = "./modules/data"
  database_configuration = {
    instance = google_sql_database_instance.shared_database_instance.name
    name     = "petclinic"
    username = "petclinic-db-user"
    password = random_password.generated_petclinic_database_password.result
  }
}

moved {
  from = google_sql_database.petclinic_database
  to   = module.petclinic_data.google_sql_database.database
}

moved {
  from = google_sql_user.petclinic_database_user
  to   = module.petclinic_data.google_sql_user.user
}