provider "google" {
  region = var.region_name
}

resource "google_storage_bucket" "tf-backend" {
  name          = var.bucket_name
  location      = upper(var.region)
  force_destroy = true
  versioning {
    enabled = true
  }
}
