resource "google_project_service" "secret_manager_enabler" {
  service = "secretmanager.googleapis.com"
}

resource "google_secret_manager_secret" "database_configuration_secret" {
  secret_id = var.secret_configuration.name
  replication {
    user_managed {
      replicas {
        location = var.secret_configuration.location
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "database_configuration_secret_value" {
  secret      = google_secret_manager_secret.database_configuration_secret.name
  secret_data = var.secret_configuration.value
}

resource "google_secret_manager_secret_iam_member" "database_configuration_secret_access" {
  secret_id  = google_secret_manager_secret.database_configuration_secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${var.secret_manager_service_account}"
  depends_on = [google_secret_manager_secret.database_configuration_secret]
}