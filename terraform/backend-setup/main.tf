provider "google" {
  region = "europe-west3"
}

resource "google_storage_bucket" "tf-backend" {
  name          = var.name
  location      = "EUROPE-WEST3"
  force_destroy = true
  versioning {
    enabled = true
  }
}