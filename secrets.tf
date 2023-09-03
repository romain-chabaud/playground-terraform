resource "google_project_service" "secret_manager_enabler" {
  service = "secretmanager.googleapis.com"
}

# voting secret
resource "google_secret_manager_secret" "voting_database_configuration_secret" {
  secret_id = "voting-db-config"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "voting_database_configuration_secret_value" {
  secret = google_secret_manager_secret.voting_database_configuration_secret.name
  secret_data = yamlencode({
    spring = {
      datasource = {
        username = google_sql_user.voting_database_user.name
        password = google_sql_user.voting_database_user.password
      }
      cloud = {
        gcp = {
          sql = {
            database-name            = google_sql_database.voting_database.name
            instance-connection-name = google_sql_database_instance.shared_database_instance.connection_name
          }
        }
      }
    }
  })
}

resource "google_secret_manager_secret_iam_member" "voting_database_configuration_secret_access" {
  secret_id  = google_secret_manager_secret.voting_database_configuration_secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.voting_database_configuration_secret]
}

# pet clinique
resource "google_secret_manager_secret" "petclinic_database_configuration_secret" {
  secret_id = "petclinic-db-config"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [google_project_service.secret_manager_enabler]
}

resource "google_secret_manager_secret_version" "petclinic_database_configuration_secret_value" {
  secret = google_secret_manager_secret.petclinic_database_configuration_secret.name
  secret_data = yamlencode({
    spring = {
      datasource = {
        username = google_sql_user.petclinic_database_user.name
        password = google_sql_user.petclinic_database_user.password
      }
      cloud = {
        gcp = {
          sql = {
            database-name            = google_sql_database.petclinic_database.name
            instance-connection-name = google_sql_database_instance.shared_database_instance.connection_name
          }
        }
      }
    }
  })
}

resource "google_secret_manager_secret_iam_member" "petclinic_database_configuration_secret_access" {
  secret_id  = google_secret_manager_secret.petclinic_database_configuration_secret.id
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_secret_manager_secret.petclinic_database_configuration_secret]
}