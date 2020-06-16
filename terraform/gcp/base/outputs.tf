output "service_address" {
  value = google_compute_address.service_address.address
  description = "IP address of services external address"
}
