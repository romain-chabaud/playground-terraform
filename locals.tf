locals {
  deployment = {
    app = {
      voting_app = {
        name  = "voting"
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.voting_repository.repository_id}/voting-app"
      }
      petclinic = {
        name  = "petclinic"
        image = "chabaudromain/petclinic"
      }
    }
  }
}