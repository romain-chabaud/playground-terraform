output "voting_app_url" {
  value = google_cloud_run_v2_service.voting_app_instance.uri
}

output "petclinic_app_url" {
  value = google_cloud_run_v2_service.petclinic_app_instance.uri
}