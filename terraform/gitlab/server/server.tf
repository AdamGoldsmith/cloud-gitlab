locals {
  instance_names = {
    for name, count in var.instance_counts : name => [
      for i in range(1, count+1) : format("%s-%02d", name, i)
    ]
  }
}

# Get CloudInit user data info
data "template_file" "user_data" {
  template = file("${path.module}/../../config/cloud_init.yml")
}

# Create Gitlab server profile
resource "lxd_profile" "server_config" {
  name        = "gitlab_server_config"
  description = "Gitlab server LXC container"

  config = {
    "limits.cpu"           = 4
    "limits.memory"        = "8192MB"
    "user.vendor-data"     = data.template_file.user_data.rendered
  }
}

# Create storage pool
resource "lxd_storage_pool" "gitlab" {
  name   = "gitlab-server"
  driver = "dir"
  config = {
    source = "/var/snap/lxd/common/lxd/storage-pools/gitlab-server"
  }
}

# Create storage volumes
resource "lxd_volume" "gitlab" {
  for_each = toset(local.instance_names.gitlab-server)
  name     = each.key
  pool     = "${lxd_storage_pool.gitlab.name}"
}

# Create gitlab server containers
resource "lxd_container" "gitlab_servers" {
  for_each   = toset(local.instance_names.gitlab-server)
  name       = each.key
  image      = "ubuntu:20.04"
  ephemeral  = false
  profiles   = ["default", lxd_profile.server_config.name]

  device {
    name = "volume1"
    type = "disk"
    properties = {
      path   = "/var/lib/docker"
      source = "${lxd_volume.gitlab[each.key].name}"
      pool   = "${lxd_storage_pool.gitlab.name}"
    }
  }
}
