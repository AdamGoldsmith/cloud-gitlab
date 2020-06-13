output "mgmt_address" {
  value = google_compute_address.mgmt_address.name
  description = "IP address of management external address"
}
