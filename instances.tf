# voting app
resource "google_project_service" "container_registry_enabler" {
  service = "containerregistry.googleapis.com"
}

resource "null_resource" "voting_app_image_creation" {
  provisioner "local-exec" {
    command = "cd voting-app/servlet && mvn clean package com.google.cloud.tools:jib-maven-plugin:2.8.0:build -Dimage=gcr.io/${var.project_id}/voting-app -DskipTests"
  }

  depends_on = [google_project_service.container_registry_enabler]
}

resource "google_project_service" "cloud_run_enabler" {
  service = "run.googleapis.com"
}

resource "google_project_service" "sql_admin_enabler" {
  service = "sqladmin.googleapis.com"
}

resource "google_cloud_run_v2_service" "voting_app_instance" {
  name     = "voting-service"
  location = var.region

  template {
    containers {
      image = "gcr.io/${var.project_id}/voting-app"

      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = google_sql_database_instance.voting_database_instance.connection_name
      }

      env {
        name  = "DB_USER"
        value = google_sql_user.voting_database_user.name
      }

      env {
        name = "DB_PASS"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.voting_database_password_secret.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "DB_NAME"
        value = google_sql_database.voting_database.name
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.voting_database_instance.connection_name]
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