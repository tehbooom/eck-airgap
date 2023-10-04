# define GCP region
variable "gcp_region" {
  type        = string
  description = "GCP region"
}

variable "gcp_zone" {
  type        = string
  description = "GCP zone"
}

variable "gce_ssh_pub_key_file" {
  type        = string
  description = "path to public ssh key file"
}

variable "project" {
  type        = string
  description = "gcp project"
}

variable "workers" {
  type        = number
  description = "number of workers"
  default     = 5
}

variable "servers" {
  type        = number
  description = "number of servers"
  default     = 3
}