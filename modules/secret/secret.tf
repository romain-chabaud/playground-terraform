resource "google_secret_manager_secret" "database_configuration_secret" {
  secret_id = var.secret_configuration.name
  replication {
    user_managed {
      replicas {
        location = var.secret_configuration.location
      }
    }
  }
}

resource "google_secret_manager_secret_version" "database_configuration_secret_value" {
  secret      = google_secret_manager_secret.database_configuration_secret.name
  secret_data = var.secret_configuration.value
}

data "google_secret_manager_secret_version_access" "secret_version_access" {
  secret = google_secret_manager_secret_version.database_configuration_secret_value.secret
}