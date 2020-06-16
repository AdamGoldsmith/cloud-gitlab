provider "google" {
  credentials = file(var.cred_file)
  project     = var.project_name
  region      = var.region_name
}

data "google_compute_network" "project_network" {
  name = "${var.network_name}-network"
}

data "google_compute_image" "centos_image" {
  family  = var.os_family_name
  project = var.os_project_name
}

data "google_compute_address" "service_address" {
  name = "service-1-address"
}

resource "google_compute_firewall" "allow_internal_vault" {
  name          = "allow-vault"
  network       = data.google_compute_network.project_network.self_link
  description   = "Internal Vault traffic - replication, request forwarding & raft gossip traffic"
  priority      = 64000

  allow {
    protocol = "tcp"
    ports    = ["8200-8201"]
  }
}

resource "google_compute_firewall" "allow_vault_api" {
  name          = "allow-vault-api"
  network       = data.google_compute_network.project_network.self_link
  description   = "External Vault API"
  priority      = 65000

  allow {
    protocol = "tcp"
    ports    = ["8200"]
  }
}

resource "google_compute_instance" "vault_instances" {
  for_each = toset(var.instance_zones)

  name         = "${var.service_name}-${random_pet.server_name[each.key].id}"
  machine_type = var.machine_type
  zone         = each.value

  boot_disk {
    initialize_params {
      image = data.google_compute_image.centos_image.self_link
      size  = var.disk_size
    }
    auto_delete = true
  }
  network_interface {
    network    = data.google_compute_network.project_network.self_link
  }
  labels = {
    ansible_group = var.service_name
  }
  tags = [var.service_name]
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pubkey)}"
  }
}

resource "google_compute_target_pool" "vault_target_pool" {
  name      = "${var.service_name}-1-target-pool"
  instances = [
    for zone in var.instance_zones : "${zone}/${google_compute_instance.vault_instances[zone].name}"
  ]
}

resource "google_compute_forwarding_rule" "vault_forwarding_rule" {
  name                  = "${var.service_name}-1-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  # TODO: Parameterise network_tier
  network_tier          = "STANDARD"
  target                = google_compute_target_pool.vault_target_pool.self_link
  ip_protocol           = var.ip_protocol
  port_range            = var.port_range
  ip_address            = data.google_compute_address.service_address.address
}
