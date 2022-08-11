variable "instance_counts" {
  type    = map(number)
  default = {
    "vault" = 3  # Key name is used for resource prefix
  }
}
