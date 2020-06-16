variable "cred_file" {
  type        = string
  description = "File containing cloud API authentication credentials"
  default     = "~/gcp/gitlab-creds.json"
}

variable "project_name" {
  type        = string
  description = "GCP project name"
}

variable "region_name" {
  type        = string
  description = "GCP region name"
}

variable "network_name" {
  type        = string
  description = "VPC project network name"
  default     = "project"
}

variable "service_name" {
  type        = string
  description = "Service function name"
}

variable "os_family_name" {
  type        = string
  description = "Use latest image from this image family and is not deprecated"
  default     = "centos-8"
}

variable "os_project_name" {
  type        = string
  description = "Project in which the image resource belongs"
  default     = "centos-cloud"
}

variable "disk_size" {
  type        = string
  description = "Size of instance boot disk"
  default     = 20
}

variable "machine_type" {
  type        = string
  description = "Cloud machine type"
}

variable "instance_zones" {
  type        = list(string)
  description = "Zones to deploy instances"
}

variable "ssh_user" {
  type        = string
  description = "User created on instances for SSH connections"
  default     = "ansible"
}

variable "ssh_pubkey" {
  type        = string
  description = "SSH public key created on instances for SSH connections"
  default     = "~/gcp/id_rsa.pub"
}

variable "ip_protocol" {
  type        = string
  description = "IP protocol for target pool load balancing"
}

variable "port_range" {
  type        = string
  description = "Port range for target pool load balancing"
}

resource "random_pet" "server_name" {
  for_each = toset(var.instance_zones)
}

# TODO: Consider potential to inject this from Ansible
# variable "allow_internal_ports" {
#   type        = map
#   description = "Allowed internal ports firewall rules"
# }