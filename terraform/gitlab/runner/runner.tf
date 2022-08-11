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

# Create Gitlab runner profile
resource "lxd_profile" "runner_config" {
  name        = "gitlab_runner_config"
  description = "Gitlab_runner LXC container"

  config = {
    "limits.cpu"           = 2
    "limits.memory"        = "2046MB"
    "user.vendor-data"     = data.template_file.user_data.rendered
  }
}

# Create storage pool
resource "lxd_storage_pool" "gitlab" {
  name   = "gitlab-runner"
  driver = "dir"
  config = {
    source = "/var/snap/lxd/common/lxd/storage-pools/gitlab-runner"
  }
}

# Create storage volumes
resource "lxd_volume" "gitlab" {
  for_each = toset(local.instance_names.gitlab-runner)
  name     = each.key
  pool     = "${lxd_storage_pool.gitlab.name}"
}

# Create gitlab runner containers
resource "lxd_container" "gitlab_runners" {
  for_each   = toset(local.instance_names.gitlab-runner)
  name       = each.key
  image      = "ubuntu:20.04"
  ephemeral  = false
  profiles   = ["default", lxd_profile.runner_config.name]

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
