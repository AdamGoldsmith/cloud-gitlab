terraform {
  backend "gcs" {
    # Change bucket name here!
    bucket = "ks-gitlab-tf-backend"
    prefix = "terraform/state"
  }
}
