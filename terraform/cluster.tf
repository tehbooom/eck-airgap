data "google_compute_image" "rhel_stig" {
  name    = "cis-red-hat-enterprise-linux-8-stig-v1-0-0-10"
  project = "cis-public"
}

## Create private container registry
resource "google_compute_instance" "registry" {
  name         = "rke2-airgap-registry"
  machine_type = "e2-standard-2"
  zone         = var.gcp_zone

  tags = ["rke2"]

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.rhel_stig.self_link
    }
  }

  attached_disk {
    source      = google_compute_disk.registry.id
    device_name = google_compute_disk.registry.name
  }

  network_interface {
    network    = google_compute_network.vpc.name
    network_ip = "192.168.1.2"
    subnetwork = google_compute_subnetwork.network_subnet.name
    access_config {}
  }

  metadata = {
    ssh-keys     = "admin:${var.gce_ssh_pub_key_file}"
    VmDnsSetting = "ZonalOnly"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

## Create loadbalancer
resource "google_compute_instance" "loadbalancer" {
  name         = "rke2-airgap-lb"
  machine_type = "e2-standard-2"
  zone         = var.gcp_zone

  tags = ["public", "rke2"]

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.rhel_stig.self_link
    }
  }

  network_interface {
    network    = google_compute_network.vpc.name
    network_ip = "192.168.1.3"
    subnetwork = google_compute_subnetwork.network_subnet.name
    access_config {
      nat_ip = google_compute_address.loadbalancer.address
    }
  }

  metadata = {
    ssh-keys     = "admin:${var.gce_ssh_pub_key_file}"
    VmDnsSetting = "ZonalOnly"
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

## Create server nodes
resource "google_compute_instance" "servers" {
  name  = "rke2-airgap-server-${count.index + 1}"
  count = var.servers
  zone  = var.gcp_zone
  machine_type   = "e2-standard-2"
  can_ip_forward = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  boot_disk {
    initialize_params {
      image = data.google_compute_image.rhel_stig.self_link
    }
  }

  metadata = {
    ssh-keys     = "admin:${var.gce_ssh_pub_key_file}"
    VmDnsSetting = "ZonalOnly"
  }

  tags = ["rke2"]

  service_account {
    scopes = ["cloud-platform"]
  }
  network_interface {
    network    = google_compute_network.vpc.name
    network_ip = "192.168.1.1${count.index}"
    subnetwork = google_compute_subnetwork.network_subnet.name
    access_config {}
  }
}

## Create worker nodes
resource "google_compute_instance" "workers" {
  name  = "rke2-airgap-worker-${count.index + 1}"
  count = var.workers
  zone  = var.gcp_zone
  machine_type   = "e2-standard-4"
  can_ip_forward = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
  boot_disk {
    initialize_params {
      image = data.google_compute_image.rhel_stig.self_link
    }
  }

  attached_disk {
    source      = google_compute_disk.worker-share[count.index].id
    device_name = google_compute_disk.worker-share[count.index].name
  }

  attached_disk {
    source      = google_compute_disk.worker-data[count.index].id
    device_name = google_compute_disk.worker-data[count.index].name
  }

  metadata = {
    ssh-keys     = "admin:${var.gce_ssh_pub_key_file}"
    VmDnsSetting = "ZonalOnly"
  }

  tags = ["rke2"]

  service_account {
    scopes = ["cloud-platform"]
  }
  network_interface {
    network    = google_compute_network.vpc.name
    network_ip = "192.168.1.2${count.index}"
    subnetwork = google_compute_subnetwork.network_subnet.name
    access_config {}
  }
}