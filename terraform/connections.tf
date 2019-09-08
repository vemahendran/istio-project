
provider "google" {
  credentials = "${file("../../credentials.json")}"
  project     = "${var.project_name}"
  region      = "${var.datacenter_location}"
}
