resource "google_project_service" "secret_manager_enabler" {
  service = "secretmanager.googleapis.com"
}

# voting secret
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

resource "google_secret_manager_secret_version" "voting_database_password_secret_value" {
  secret      = google_secret_manager_secret.voting_database_password_secret.name
  secret_data = google_sql_user.voting_database_user.password
}

resource "google_secret_manager_secret_iam_member" "voting_database_password_secret_access" {
  secret_id  = google_secret_manager_secret.voting_database_password_secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.voting_database_password_secret]
}

data "google_secret_manager_secret_version_access" "latest_voting_database_password_secret_value" {
  secret = google_secret_manager_secret_version.voting_database_password_secret_value.secret
}

# pet clinique
resource "google_secret_manager_secret" "petclinic_database_password_secret" {
  secret_id = "petclinic-db-password"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "petclinic_database_password_secret_value" {
  secret      = google_secret_manager_secret.petclinic_database_password_secret.name
  secret_data = google_sql_user.petclinic_database_user.password
}

resource "google_secret_manager_secret_iam_member" "petclinic_database_password_secret_access" {
  secret_id  = google_secret_manager_secret.petclinic_database_password_secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.petclinic_database_password_secret]
}

data "google_secret_manager_secret_version_access" "latest_petclinic_database_password_secret_value" {
  secret = google_secret_manager_secret_version.petclinic_database_password_secret_value.secret
}