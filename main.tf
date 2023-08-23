# project details
data "google_project" "project" {
}

# database
resource "google_project_service" "enable_sql_admin" {
  service = "sqladmin.googleapis.com"
}

resource "google_sql_database" "voting_database" {
  name     = "voting_db"
  instance = google_sql_database_instance.voting_database_instance.name
}

resource "google_sql_database_instance" "voting_database_instance" {
  name             = "voting-db-instance"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "voting_db_user" {
  name     = "voting-db-user"
  instance = google_sql_database_instance.voting_database_instance.name
  password = random_password.generated_db_password.result
}

# instance
resource "google_project_service" "enable_voting_instance" {
  service = "run.googleapis.com"
}

resource "google_project_service" "enable_container_registry" {
  service = "containerregistry.googleapis.com"
}

resource "null_resource" "voting_app_image_creation" {
  provisioner "local-exec" {
    command = "cd voting-app/servlet && mvn clean package com.google.cloud.tools:jib-maven-plugin:2.8.0:build -Dimage=gcr.io/${var.project_id}/voting-app -DskipTests"
  }

  depends_on = [google_project_service.enable_container_registry]
}

resource "google_cloud_run_v2_service" "voting_service" {
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
        value = google_sql_user.voting_db_user.name
      }

      env {
        name = "DB_PASS"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password_secret.secret_id
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
    google_project_service.enable_voting_instance,
    google_project_service.enable_sql_admin,
    null_resource.voting_app_image_creation,
    google_secret_manager_secret_version.db_password_secret_value
  ]
}

resource "google_cloud_run_v2_service_iam_member" "instance_members_access" {
  project  = google_cloud_run_v2_service.voting_service.project
  location = google_cloud_run_v2_service.voting_service.location
  name     = google_cloud_run_v2_service.voting_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# secret
resource "random_password" "generated_db_password" {
  length = var.db_password_length >= var.min_db_password_length ? var.db_password_length : var.min_db_password_length
}

resource "google_project_service" "enable_secret_manager" {
  service = "secretmanager.googleapis.com"
}

resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "voting-db-password"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.enable_secret_manager]
}

resource "google_secret_manager_secret_version" "db_password_secret_value" {
  secret      = google_secret_manager_secret.db_password_secret.name
  secret_data = google_sql_user.voting_db_user.password
}

resource "google_secret_manager_secret_iam_member" "secret_access" {
  secret_id  = google_secret_manager_secret.db_password_secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.db_password_secret]
}