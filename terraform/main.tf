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

// Provides access to available Google Container Engine versions in a zone for a given project.
// https://www.terraform.io/docs/providers/google/d/google_container_engine_versions.html
data "google_container_engine_versions" "on-prem" {
  zone    = var.zone
  project = var.project
}

// https://www.terraform.io/docs/providers/google/r/google_container_cluster.html
// Create the primary cluster for this project.

module "network" {
  source   = "./modules/network"
  project  = var.project
  region   = var.region
  vpc_name = var.vpc_name
}

module "firewall" {
  source   = "./modules/firewall"
  project  = var.project
  vpc_name = module.network.network_self_link
  net_tags = var.bastion_tags
}

module "bastion" {
  source                = "./modules/instance"
  project               = var.project
  hostname              = "gke-tutorial-admin"
  machine_type          = var.bastion_machine_type
  zone                  = var.zone
  tags                  = var.bastion_tags
  cluster_subnet        = module.network.subnet_self_link
  cluster_name          = var.cluster_name
  owner_email           = google_service_account.owner.email
  auditor_email         = google_service_account.auditor.email
  service_account_email = google_service_account.admin.email
  grant_cluster_admin   = "1"
}

module "owner_instance" {
  source                = "./modules/instance"
  project               = var.project
  hostname              = "gke-tutorial-owner"
  machine_type          = var.bastion_machine_type
  zone                  = var.zone
  tags                  = var.bastion_tags
  cluster_subnet        = module.network.subnet_self_link
  cluster_name          = var.cluster_name
  owner_email           = google_service_account.owner.email
  auditor_email         = google_service_account.auditor.email
  service_account_email = google_service_account.owner.email
}

module "auditor_instance" {
  source                = "./modules/instance"
  project               = var.project
  hostname              = "gke-tutorial-auditor"
  machine_type          = var.bastion_machine_type
  zone                  = var.zone
  tags                  = var.bastion_tags
  cluster_subnet        = module.network.subnet_self_link
  cluster_name          = var.cluster_name
  owner_email           = google_service_account.owner.email
  auditor_email         = google_service_account.auditor.email
  service_account_email = google_service_account.auditor.email
}

resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  project            = var.project
  zone               = var.zone
  network            = module.network.network_self_link
  subnetwork         = module.network.subnet_self_link
  min_master_version = data.google_container_engine_versions.on-prem.latest_master_version
  initial_node_count = var.initial_node_count

  lifecycle {
    ignore_changes = [ip_allocation_policy[0].services_secondary_range_name]
  }

  node_locations = []

  // Scopes necessary for the nodes to function correctly
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    machine_type = var.node_machine_type
    image_type   = "COS"

    // (Optional) The Kubernetes labels (key/value pairs) to be applied to each node.
    labels = {
      status = "poc"
    }

    // (Optional) The list of instance tags applied to all nodes.
    // Tags are used to identify valid sources or targets for network firewalls.
    tags = ["poc"]
  }

  // (Required for private cluster, optional otherwise) Configuration for cluster IP allocation.
  // As of now, only pre-allocated subnetworks (custom type with
  // secondary ranges) are supported. This will activate IP aliases.
  ip_allocation_policy {
    cluster_secondary_range_name  = "secondary-range"
  }

  // In a private cluster, the master has two IP addresses, one public and one
  // private. Nodes communicate to the master through this private IP address.
  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = "10.0.90.0/28"
  }

  // (Required for private cluster, optional otherwise) network (cidr) from which cluster is accessible
  master_authorized_networks_config {
    cidr_blocks {
      display_name = "gke-tutorial-admin"
      cidr_block   = join("/", [module.bastion.external_ip,"32"])
    }
    cidr_blocks {
      display_name = "gke-tutorial-owner"
      cidr_block   = join("/", [module.owner_instance.external_ip,"32"])
//      cidr_block   = "${module.owner_instance.external_ip}/32"
    }
    cidr_blocks {
      display_name = "gke-tutorial-auditor"
      cidr_block   = join("/", [module.auditor_instance.external_ip,"32"])
//      cidr_block   = "${module.auditor_instance.external_ip}/32"
    }
  }

  // (Required for Calico, optional otherwise) Configuration options for the NetworkPolicy feature
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  // (Required for network_policy enabled cluster, optional otherwise)
  // Addons config supports other options as well, see:
  // https://www.terraform.io/docs/providers/google/r/container_cluster.html#addons_config
  addons_config {
    network_policy_config {
      disabled = false
    }
  }
}

