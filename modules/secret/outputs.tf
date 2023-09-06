output "secret_value" {
  value     = data.google_secret_manager_secret_version_access.secret_version_access.secret_data
  sensitive = true
}