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

resource "google_compute_address" "mgmt_address" {
  name = "mgmt-1-address"
  description = "Management external address"
  network_tier = "STANDARD"
}

resource "google_compute_instance" "bastion_instances" {
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
    access_config {
      nat_ip = google_compute_address.mgmt_address.address
      network_tier = "STANDARD"
    }
  }
  labels = {
    ansible_group = var.service_name
  }
  tags = [var.service_name]
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pubkey)}"
  }
}
