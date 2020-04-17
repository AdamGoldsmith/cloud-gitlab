module vpc {
  source = "tasdikrahman/network/google"
  name   = local.vpc_name
}

module subnet {
  source        = "tasdikrahman/network-subnet/google"
  name          = "gitlab-subnet"
  vpc           = module.vpc.name
  ip_cidr_range = local.gitlab_cidr
}


resource "google_compute_firewall" "gitlab_fw_local" {
  name    = "gitlab-firewall-local"
  network = module.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_tags = ["gitlab"]
}

resource "google_compute_firewall" "gitlab_fw_external" {
  name    = "gitlab-firewall-external"
  network = module.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "4483"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource google_compute_address static {
  name = "gitlab-static-ip"
}

