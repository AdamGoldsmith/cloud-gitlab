variable "instance_counts" {
  type    = map(number)
  default = {
    "gitlab-runner" = 2  # Key name is used for resource prefix
  }
}
