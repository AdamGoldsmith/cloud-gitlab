data "google_compute_image" "centos_image" {
  family  = "centos-8"
  project = "centos-cloud"
}

resource "google_compute_instance" "instance_with_ip" {
  name         = local.instance_name
  machine_type = local.instance_type
  zone         = local.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.centos_image.self_link
      size  = 50
    }
    auto_delete = true
  }

  network_interface {
    network    = module.vpc.self_link
    subnetwork = module.subnet.self_link
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
  labels = {
    ansible_group = "${local.instance_name}-gitlab"
  }
  tags = ["gitlab"]
  metadata = {
    ssh-keys = "${local.ssh_user}:${file(local.ssh_pubkey)}"
  }

}