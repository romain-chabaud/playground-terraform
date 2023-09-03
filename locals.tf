locals {
  deployment = {
    shared_db_instance = google_sql_database_instance.shared_database_instance.connection_name
    app = {
      voting_app = {
        name  = "voting-service"
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.voting_repository.repository_id}/voting-app"
        db = {
          name     = module.voting_data.database_name
          user     = module.voting_data.database_user
          password = module.voting_data.database_password
        }
      }
      petclinic = {
        name  = "petclinic-service"
        image = "chabaudromain/petclinic-cloudsql-postgres"
        db = {
          name     = module.petclinic_data.database_name
          user     = module.petclinic_data.database_user
          password = module.petclinic_data.database_password
        }
      }
    }
  }
}

locals {
  default_service_account = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}