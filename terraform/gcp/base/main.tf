provider "google" {
  credentials = file(var.cred_file)
  project     = var.project_name
  region      = var.region_name
}

resource "google_compute_network" "vpc_network" {
  name                    = "${var.network_name}-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "allow_internal" {
  name          = "allow-internal"
  network       = google_compute_network.vpc_network.name
  description   = "Allow all UDP/TCP ports & ICMP internally"
  priority      = 65534
  source_ranges = ["10.128.0.0/9"]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_external" {
  name          = "allow-icmp"
  network       = google_compute_network.vpc_network.name
  description   = "Allow ICMP externally"
  priority      = 65534

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc_network.name
  description   = "Allow SSH externally"
  priority      = 65534

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_router" "project_router" {
  name        = "${var.network_name}-router"
  network     = google_compute_network.vpc_network.name
  description = "Project router to use with Cloud NAT"
  region      = var.region_name
  # TODO: Required?
  # bgp {
  #   asn               = 64514
  #   advertise_mode    = "CUSTOM"
  #   advertised_groups = ["ALL_SUBNETS"]
  #   advertised_ip_ranges {
  #     range = "1.2.3.4"
  #   }
  #   advertised_ip_ranges {
  #     range = "6.7.0.0/16"
  #   }
  # }
}

resource "google_compute_router_nat" "project_nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.project_router.name
  region                             = var.region_name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # TODO: Useful?
  # log_config {
  #   enable = true
  #   filter = "ERRORS_ONLY"
  # }
}

resource "google_compute_address" "service_address" {
  name = "service-1-address"
  description = "Services external address"
  network_tier = "STANDARD"
}
