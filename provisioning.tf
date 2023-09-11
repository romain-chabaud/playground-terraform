# voting data
module "voting_data" {
  source     = "github.com/romain-chabaud/playground-terraform-data-module.git"
  app_name   = "voting_app"
  app_region = var.region
  database_configuration = {
    instance = {
      name   = var.database_instance_name
      exists = false
    }
    password_generation = {
      desired_password_length = var.voting_database_desired_password_length
    }
  }
}

# petclinic data
module "petclinic_data" {
  source     = "github.com/romain-chabaud/playground-terraform-data-module.git"
  app_name   = "petclinic"
  app_region = var.region
  database_configuration = {
    instance = {
      name   = module.voting_data.database_configuration.instance_name
      exists = true
    }
    database_name = "petclinic"
    password_generation = {
      desired_password_length = var.petclinic_database_desired_password_length
    }
  }

  depends_on = [module.voting_data.database_configuration]
}
