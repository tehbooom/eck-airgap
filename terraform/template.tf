resource "local_file" "ansible_inventory" {
  filename = "../ansible/hosts.ini"
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      ip_worker   = google_compute_instance.workers.*.network_interface.0.access_config.0.nat_ip,
      ip_server   = google_compute_instance.servers.*.network_interface.0.access_config.0.nat_ip,
      ip_registry = google_compute_instance.registry.*.network_interface.0.access_config.0.nat_ip,
      ip_lb       = google_compute_instance.loadbalancer.*.network_interface.0.access_config.0.nat_ip,
      zone        = var.gcp_zone,
      project     = var.project
    }
  )
}

resource "local_file" "registry" {
  filename = "../ansible/registries.yml"
  content = templatefile("${path.module}/templates/registries.tpl",
    {
      zone    = var.gcp_zone,
      project = var.project
    }
  )
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "local_file" "server_vars" {
  filename = "../ansible/group_vars/rke2_servers.yml"
  content = templatefile("${path.module}/templates/rke2_server.tpl",
    {
      ip      = google_compute_instance.loadbalancer.network_interface.0.access_config.0.nat_ip,
      zone    = var.gcp_zone,
      project = var.project,
      token   = random_password.password.result
    }
  )
}