locals {
  deployment = {
    shared_db_instance = google_sql_database_instance.shared_database_instance.connection_name
    app = {
      voting_app = {
        name  = "voting-service"
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.voting_repository.repository_id}/voting-app"
        db = {
          name     = google_sql_database.voting_database.name
          user     = google_sql_user.voting_database_user.name
          password = google_sql_user.voting_database_user.password
        }
      }
      petclinic = {
        name  = "petclinic-service"
        image = "chabaudromain/petclinic-cloudsql-postgres"
        db = {
          name     = google_sql_database.petclinic_database.name
          user     = google_sql_user.petclinic_database_user.name
          password = google_sql_user.petclinic_database_user.password
        }
      }
    }
  }
}