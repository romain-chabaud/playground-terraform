# project details
data "google_project" "project" {
}

# database
resource "google_sql_database" "hello_database" {
  name     = "hello_db"
  instance = google_sql_database_instance.hello_database_instance.name
}

resource "google_sql_database_instance" "hello_database_instance" {
  name             = "hello-db-instance"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "hello_db_user" {
  name     = "hello-db-user"
  instance = google_sql_database_instance.hello_database_instance.name
  password = random_password.generated_db_password.result
}

# instance
resource "google_project_service" "enable_instance" {
  service = "run.googleapis.com"
}

resource "google_cloud_run_v2_service" "hello_service" {
  name     = "hello-service"
  location = var.region

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  depends_on = [google_project_service.enable_instance]
}

resource "google_cloud_run_v2_service_iam_member" "instance_members_access" {
  project  = google_cloud_run_v2_service.hello_service.project
  location = google_cloud_run_v2_service.hello_service.location
  name     = google_cloud_run_v2_service.hello_service.name
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
  secret_id = "hello-db-password"
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
  secret_data = google_sql_user.hello_db_user.password
}

resource "google_secret_manager_secret_iam_member" "secret_access" {
  secret_id  = google_secret_manager_secret.db_password_secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.db_password_secret]
}