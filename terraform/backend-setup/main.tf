provider "google" {
  region = "europe-west2"
}

resource "google_storage_bucket" "tf-backend" {
  name          = var.name
  location      = "EUROPE-WEST2"
  force_destroy = true
  versioning {
    enabled = true
  }
}
