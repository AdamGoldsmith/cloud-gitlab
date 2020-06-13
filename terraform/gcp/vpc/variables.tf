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

# TODO: Consider potential to inject this from Ansible
# variable "allow_internal_ports" {
#   type        = map
#   description = "Allowed internal ports firewall rules"
# }
