## Create VPC
resource "google_compute_network" "vpc" {
  name                    = "rke2-airgap-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

## Create subnet
resource "google_compute_subnetwork" "network_subnet" {
  name          = "rke2-airgap-subnet"
  ip_cidr_range = "192.168.1.0/24"
  network       = google_compute_network.vpc.name
  region        = var.gcp_region
}

## Allow anyone to SSH to all nodes
resource "google_compute_firewall" "allow-all-ssh" {
  name    = "rke2-airgap-vpc-allow-ssh"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

## Allow anyone to hit the loadbalancer for HTTPS and kubectl
resource "google_compute_firewall" "allow-all-public" {
  name    = "rke2-airgap-vpc-allow-all-public"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["9345", "6443", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["public"]
}

## Allow rke2 TCP ports
resource "google_compute_firewall" "rke2" {
  name    = "rke2-airgap-all-internal"
  network = google_compute_network.vpc.name
  allow {
    protocol = "all"
  }
  source_tags = ["rke2"]
  target_tags = ["rke2"]
}

resource "google_compute_address" "loadbalancer" {
  name = "rke2-loadbalancer"
}