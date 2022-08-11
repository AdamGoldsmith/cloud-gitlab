variable "instance_counts" {
  type    = map(number)
  default = {
    "gitlab-server" = 1  # Key name is used for resource prefix
  }
}
