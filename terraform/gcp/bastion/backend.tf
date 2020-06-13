terraform {
  backend "gcs" {
    # Backend configuration supplied via `-backend-config` eg
    # credentials = "~/gcp/creds.json"
    # bucket      = "bucket-name"
    # prefix      = "terraform/state"
  }
}
