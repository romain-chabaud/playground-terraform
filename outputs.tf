output "app_url" {
  value = google_cloud_run_v2_service.hello_service.uri
}