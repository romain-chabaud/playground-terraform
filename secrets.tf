# voting secret
resource "google_project_service" "secret_manager_enabler" {
  service = "secretmanager.googleapis.com"
}

resource "google_secret_manager_secret" "voting_database_password_secret" {
  secret_id = "voting-db-password"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "random_password" "generated_voting_database_password" {
  length = var.voting_db_password_length >= var.min_db_password_length ? var.voting_db_password_length : var.min_db_password_length
}

resource "google_secret_manager_secret_version" "voting_database_password_secret_value" {
  secret      = google_secret_manager_secret.voting_database_password_secret.name
  secret_data = random_password.generated_voting_database_password.result
}

resource "google_secret_manager_secret_iam_member" "voting_database_password_secret_access" {
  secret_id  = google_secret_manager_secret.voting_database_password_secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.voting_database_password_secret]
}