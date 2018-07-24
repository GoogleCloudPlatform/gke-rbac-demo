/*
Copyright 2018 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// This file creates a custom VPC network and subnet to contain the
// GKE cluster.

// https://www.terraform.io/docs/providers/google/d/datasource_compute_subnetwork.html
// Subnetwork for the GKE cluster.
resource "google_compute_subnetwork" "cluster-subnet" {
  name          = "${var.vpc_name}-subnet"
  project       = "${var.project}"
  ip_cidr_range = "${var.ip_range}"
  network       = "${google_compute_network.gke-network.self_link}"
  region        = "${var.region}"

  // A named secondary range is mandatory for a private cluster, this creates it.
  secondary_ip_range {
    range_name    = "secondary-range"
    ip_cidr_range = "${var.secondary_ip_range}"
  }
}

// https://www.terraform.io/docs/providers/google/d/datasource_compute_network.html
// A network to hold just the GKE cluster, not recommended for other instances.
resource "google_compute_network" "gke-network" {
  name                    = "${var.vpc_name}"
  project                 = "${var.project}"
  auto_create_subnetworks = false
}
