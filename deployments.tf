# voting app
resource "google_project_service" "artifact_registry_enabler" {
  service = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "voting_repository" {
  location      = var.region
  repository_id = "voting-repository"
  format        = "DOCKER"

  depends_on = [google_project_service.artifact_registry_enabler]
}

resource "null_resource" "voting_app_image_creation" {
  provisioner "local-exec" {
    command = "cd code/voting-app/servlet && mvn clean package com.google.cloud.tools:jib-maven-plugin:2.8.0:build -Dimage=${local.deployment.app.voting_app.image} -DskipTests"
  }

  depends_on = [google_artifact_registry_repository.voting_repository]
}

module "voting_run" {
  source   = "github.com/romain-chabaud/playground-terraform-run-module.git"
  app_name = local.deployment.app.voting_app.name
  env = {
    INSTANCE_HOST = module.voting_data.database_configuration.public_ip
    DB_PORT       = module.voting_data.database_configuration.port
    DB_NAME       = module.voting_data.database_configuration.database_name
    DB_USER       = module.voting_data.database_configuration.username
    DB_PASS       = module.voting_data.database_configuration.password
  }
  image  = local.deployment.app.voting_app.image
  region = var.region

  depends_on = [
    null_resource.voting_app_image_creation
  ]
}

# petclinic app
module "petclinic_run" {
  source   = "github.com/romain-chabaud/playground-terraform-run-module.git"
  app_name = local.deployment.app.petclinic.name
  env = {
    SPRING_PROFILES_ACTIVE = "postgres"
    POSTGRES_URL           = "jdbc:postgresql://${module.petclinic_data.database_configuration.public_ip}:${module.petclinic_data.database_configuration.port}/${module.petclinic_data.database_configuration.database_name}"
    POSTGRES_USER          = module.petclinic_data.database_configuration.username
    POSTGRES_PASS          = module.petclinic_data.database_configuration.password
  }
  image  = local.deployment.app.petclinic.image
  region = var.region
}