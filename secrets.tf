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
}