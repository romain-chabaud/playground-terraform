locals {
  deployment = {
    app = {
      voting_app = {
        name  = "voting-service"
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.voting_repository.repository_id}/voting-app"
      }
      petclinic = {
        name  = "petclinic-service"
        image = "chabaudromain/petclinic-cloudsql-postgres"
      }
    }
  }
}

locals {
  default_service_account = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}