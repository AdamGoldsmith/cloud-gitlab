output "mgmt_address" {
  value = google_compute_address.mgmt_address.address
  description = "IP address of management external address"
}
