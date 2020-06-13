variable "bucket_name" {
  type        = string
  description = "Name of bucket for storing remote state files"
}

variable "region_name" {
  type        = string
  description = "Region to create bucket"
}