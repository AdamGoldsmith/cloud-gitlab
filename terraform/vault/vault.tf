locals {
  instance_names = {
    for name, count in var.instance_counts : name => [
      for i in range(1, count+1) : format("%s-%02d", name, i)
    ]
  }
}

# Get CloudInit user data info
data "template_file" "user_data" {
  template = file("${path.module}/../config/cloud_init.yml")
}

# Create Gitlab server profile
resource "lxd_profile" "server_config" {
  name        = "vault_config"
  description = "Vault server LXC container"

  config = {
    "limits.cpu"           = 2
    "limits.memory"        = "2048MB"
    "user.vendor-data"     = data.template_file.user_data.rendered
  }
}

# Create storage pool
resource "lxd_storage_pool" "vault" {
  name   = "vault"
  driver = "dir"
  config = {
    source = "/var/snap/lxd/common/lxd/storage-pools/vault"
  }
}

# Create storage volumes
resource "lxd_volume" "vault" {
  for_each = toset(local.instance_names.vault)
  name     = each.key
  pool     = "${lxd_storage_pool.vault.name}"
}

# Create vault containers
resource "lxd_container" "vault" {
  for_each   = toset(local.instance_names.vault)
  name       = each.key
  image      = "ubuntu:20.04"
  ephemeral  = false
  profiles   = ["default", lxd_profile.server_config.name]

  device {
    name = "volume1"
    type = "disk"
    properties = {
      path   = "/var/lib/docker"
      source = "${lxd_volume.vault[each.key].name}"
      pool   = "${lxd_storage_pool.vault.name}"
    }
  }
}
