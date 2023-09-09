resource "google_project_service" "secret_manager_enabler" {
  service = "secretmanager.googleapis.com"
}

# voting secret
module "voting_secret" {
  source = "./modules/secret"
  secret_configuration = {
    name     = "voting-db-config"
    location = var.region
    value = jsonencode({
      INSTANCE_HOST = google_sql_database_instance.shared_database_instance.public_ip_address
      DB_PORT       = local.default_database_port
      DB_NAME       = module.voting_data.database_name
      DB_USER       = module.voting_data.database_user
      DB_PASS       = module.voting_data.database_password
    })
  }

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
    value = jsonencode({
      SPRING_PROFILES_ACTIVE = "postgres"
      POSTGRES_URL           = "jdbc:postgresql://${google_sql_database_instance.shared_database_instance.public_ip_address}:${local.default_database_port}/${module.petclinic_data.database_name}"
      POSTGRES_USER          = module.petclinic_data.database_user
      POSTGRES_PASS          = module.petclinic_data.database_password
    })
  }

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