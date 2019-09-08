
resource "google_container_cluster" "pirates" {
  name               = "${var.cluster_name}"
  location           = "${var.datacenter_location}"
  initial_node_count = "3"

  node_locations = [
    # "us-west1-b"
  ]

  master_auth {
    password = "password_must_be_16_characters"
    username = "username"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]

    labels = {
      this-is-for = "dev-cluster"
    }

    tags = ["dev", "work"]

  }


}
