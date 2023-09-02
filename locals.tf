locals {
  deployment = {
    shared_db_instance = google_sql_database_instance.shared_database_instance.connection_name
    app = {
      voting_app = {
        name  = "voting-service"
        image = "gcr.io/${var.project_id}/voting-app"
        db = {
          name     = google_sql_database.voting_database.name
          user     = google_sql_user.voting_database_user.name
          password = data.google_secret_manager_secret_version_access.latest_voting_database_password_secret_value.secret_data
        }
      }
      petclinic = {
        name  = "petclinic-service"
        image = "chabaudromain/petclinic-cloudsql-postgres"
        db = {
          name     = google_sql_database.petclinic_database.name
          user     = google_sql_user.petclinic_database_user.name
          password = data.google_secret_manager_secret_version_access.latest_petclinic_database_password_secret_value.secret_data
        }
      }
    }
  }
}