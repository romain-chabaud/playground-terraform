resource "google_project_service" "artifact_registry_enabler" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "cloud_run_enabler" {
  service = "run.googleapis.com"
}

resource "google_project_service" "sql_admin_enabler" {
  service = "sqladmin.googleapis.com"
}

# voting app
resource "google_artifact_registry_repository" "voting_repository" {
  location      = var.region
  repository_id = "voting-repository"
  format        = "DOCKER"

  depends_on = [google_project_service.artifact_registry_enabler]
}

resource "null_resource" "voting_app_image_creation" {
  provisioner "local-exec" {
    command = "cd code/voting-app/servlet && mvn clean package com.google.cloud.tools:jib-maven-plugin:2.8.0:build -Dimage=${local.deployment.app.voting_app.image} -DskipTests"
  }

  depends_on = [google_artifact_registry_repository.voting_repository]
}

resource "google_service_account" "voting_app_run_service_account" {
  account_id = "voting-app-run-sa"
}

resource "google_cloud_run_v2_service" "voting_app_run_service" {
  name     = local.deployment.app.voting_app.name
  location = var.region

  template {
    service_account = google_service_account.voting_app_run_service_account.email
    containers {
      image = local.deployment.app.voting_app.image

      dynamic "env" {
        for_each = jsondecode(nonsensitive(module.voting_secret.secret_value))
        content {
          name  = env.key
          value = sensitive(env.value)
        }
      }
    }
  }

  depends_on = [
    google_project_service.cloud_run_enabler,
    google_project_service.sql_admin_enabler,
    null_resource.voting_app_image_creation
  ]
}

resource "google_cloud_run_v2_service_iam_member" "voting_app_run_service_access" {
  project  = google_cloud_run_v2_service.voting_app_run_service.project
  location = google_cloud_run_v2_service.voting_app_run_service.location
  name     = google_cloud_run_v2_service.voting_app_run_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# petclinic app
resource "google_service_account" "petclinic_app_run_service_account" {
  account_id = "petclinic-app-run-sa"
}

resource "google_cloud_run_v2_service" "petclinic_app_run_service" {
  name     = local.deployment.app.petclinic.name
  location = var.region

  template {
    service_account = google_service_account.petclinic_app_run_service_account.email
    containers {
      image = local.deployment.app.petclinic.image

      resources {
        limits = {
          memory = "1Gi"
        }
      }

      dynamic "env" {
        for_each = jsondecode(nonsensitive(module.petclinic_secret.secret_value))
        content {
          name  = env.key
          value = sensitive(env.value)
        }
      }
    }
  }

  depends_on = [
    google_project_service.cloud_run_enabler,
    google_project_service.sql_admin_enabler
  ]
}

resource "google_cloud_run_v2_service_iam_member" "petclinic_app_run_service_access" {
  project  = google_cloud_run_v2_service.petclinic_app_run_service.project
  location = google_cloud_run_v2_service.petclinic_app_run_service.location
  name     = google_cloud_run_v2_service.petclinic_app_run_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}