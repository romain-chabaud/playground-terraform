output "voting_app_url" {
  value = google_cloud_run_v2_service.voting_app_run_service.uri
}

output "petclinic_app_url" {
  value = google_cloud_run_v2_service.petclinic_app_run_service.uri
}