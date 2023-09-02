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
}

resource "null_resource" "voting_app_image_creation" {
  provisioner "local-exec" {
    command = "cd code/voting-app/servlet && mvn clean package com.google.cloud.tools:jib-maven-plugin:2.8.0:build -Dimage=${local.deployment.app.voting_app.image} -DskipTests"
  }

  depends_on = [google_artifact_registry_repository.voting_repository]
}

resource "google_cloud_run_v2_service" "voting_app_instance" {
  name     = local.deployment.app.voting_app.name
  location = var.region

  template {
    containers {
      image = local.deployment.app.voting_app.image

      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = local.deployment.shared_db_instance
      }

      env {
        name  = "DB_USER"
        value = local.deployment.app.voting_app.db.user
      }

      env {
        name  = "DB_PASS"
        value = local.deployment.app.voting_app.db.password
      }

      env {
        name  = "DB_NAME"
        value = local.deployment.app.voting_app.db.name
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.shared_database_instance.connection_name]
      }
    }
  }

  depends_on = [
    google_project_service.cloud_run_enabler,
    google_project_service.sql_admin_enabler,
    null_resource.voting_app_image_creation,
    google_secret_manager_secret_version.voting_database_password_secret_value
  ]
}

resource "google_cloud_run_v2_service_iam_member" "voting_app_instance_access" {
  project  = google_cloud_run_v2_service.voting_app_instance.project
  location = google_cloud_run_v2_service.voting_app_instance.location
  name     = google_cloud_run_v2_service.voting_app_instance.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# petclinic app
resource "google_cloud_run_v2_service" "petclinic_app_instance" {
  name     = local.deployment.app.petclinic.name
  location = var.region

  template {
    containers {
      image = local.deployment.app.petclinic.image

      resources {
        limits = {
          memory = "1Gi"
        }
      }

      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = local.deployment.shared_db_instance
      }

      env {
        name  = "DB_USER"
        value = local.deployment.app.petclinic.db.user
      }

      env {
        name  = "DB_PASS"
        value = local.deployment.app.petclinic.db.password
      }
    }
  }

  depends_on = [
    google_project_service.cloud_run_enabler,
    google_project_service.sql_admin_enabler
  ]
}

resource "google_cloud_run_v2_service_iam_member" "petclinic_app_instance_access" {
  project  = google_cloud_run_v2_service.petclinic_app_instance.project
  location = google_cloud_run_v2_service.petclinic_app_instance.location
  name     = google_cloud_run_v2_service.petclinic_app_instance.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}