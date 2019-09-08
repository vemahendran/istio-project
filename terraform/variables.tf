
// Google Compute Platform variables

variable cluster_name {
  default     = "caribbean-cluster"
  type        = "string"
  description = "The GCP cluster name"
}

variable project_name {
  default     = "thrashingcorecode-249409"
  type        = "string"
  description = "GCP project name"
}

variable datacenter_location {
  default     = "us-west1-a"
  type        = "string"
  description = "GCP datatcenter"
}

variable subnet_names {
  type = "map"

  default = {
    subnet1 = "subnetone"
    subnet2 = "subnettwo"
    subnet3 = "subnetthree"
  }
}

output "cluster_name" {
  value = "${google_container_cluster.pirates.name}"
}

output "cluster_location" {
  value = "${google_container_cluster.pirates.location}"
}

output "cluster_ipv4_cidr" {
  value = "${google_container_cluster.pirates.cluster_ipv4_cidr}"
}
