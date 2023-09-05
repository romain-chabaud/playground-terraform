resource "google_project_service" "secret_manager_enabler" {
  service = "secretmanager.googleapis.com"
}

# voting secret
module "voting_secret" {
  source = "./modules/secret"
  secret_configuration = {
    name     = "voting-db-config"
    location = var.region
    value = yamlencode({
      spring = {
        datasource = {
          username = module.voting_data.database_user
          password = module.voting_data.database_password
        }
        cloud = {
          gcp = {
            sql = {
              database-name            = module.voting_data.database_name
              instance-connection-name = google_sql_database_instance.shared_database_instance.connection_name
            }
          }
        }
      }
    })
  }
  secret_manager_service_account = local.default_service_account

  depends_on = [google_project_service.secret_manager_enabler]
}

moved {
  from = google_secret_manager_secret.voting_database_configuration_secret
  to   = module.voting_secret.google_secret_manager_secret.database_configuration_secret
}

moved {
  from = google_secret_manager_secret_version.voting_database_configuration_secret_value
  to   = module.voting_secret.google_secret_manager_secret_version.database_configuration_secret_value
}

moved {
  from = google_secret_manager_secret_iam_member.voting_database_configuration_secret_access
  to   = module.voting_secret.google_secret_manager_secret_iam_member.database_configuration_secret_access
}

# pet clinique
module "petclinic_secret" {
  source = "./modules/secret"
  secret_configuration = {
    name     = "petclinic-db-config"
    location = var.region
    value = yamlencode({
      spring = {
        datasource = {
          username = module.petclinic_data.database_user
          password = module.petclinic_data.database_password
        }
        cloud = {
          gcp = {
            sql = {
              database-name            = module.petclinic_data.database_name
              instance-connection-name = google_sql_database_instance.shared_database_instance.connection_name
            }
          }
        }
      }
    })
  }
  secret_manager_service_account = local.default_service_account

  depends_on = [google_project_service.secret_manager_enabler]
}

moved {
  from = google_secret_manager_secret.petclinic_database_configuration_secret
  to   = module.petclinic_secret.google_secret_manager_secret.database_configuration_secret
}

moved {
  from = google_secret_manager_secret_version.petclinic_database_configuration_secret_value
  to   = module.petclinic_secret.google_secret_manager_secret_version.database_configuration_secret_value
}

moved {
  from = google_secret_manager_secret_iam_member.petclinic_database_configuration_secret_access
  to   = module.petclinic_secret.google_secret_manager_secret_iam_member.database_configuration_secret_access
}