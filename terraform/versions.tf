terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.77.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.gcp_region
  zone    = var.gcp_zone
}