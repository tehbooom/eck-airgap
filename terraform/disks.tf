
resource "google_compute_disk" "registry" {
  name = "rke2-registry-disk-data"
  type = "pd-standard"
  zone = var.gcp_zone
  size = "100"
}

resource "google_compute_disk" "worker-share" {
  name  = "rke2-worker-${count.index + 1}-disk-share"
  count = var.workers
  type  = "pd-standard"
  zone  = var.gcp_zone
  size  = "100"
}

resource "google_compute_disk" "worker-data" {
  name  = "rke2-worker-${count.index + 1}-disk-data"
  count = var.workers
  type  = "pd-standard"
  zone  = var.gcp_zone
  size  = "100"
}