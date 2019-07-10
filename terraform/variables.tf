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

/*
This file exposes variables that can be overridden to customize your cloud configuration.
https://www.terraform.io/docs/configuration/variables.html
*/

/*
Required Variables
These must be provided at runtime.
*/

variable "zone" {
  description = "The zone in which to create the Kubernetes cluster. Must match the region"
  type        = string
}

variable "region" {
  description = "The region in which to create the Kubernetes cluster."
  type        = string
}

variable "project" {
  description = "The name of the project in which to create the Kubernetes cluster."
  type        = string
}

/*
Optional Variables
Defaults will be used for these, if not overridden at runtime.
*/

variable "vpc_name" {
  description = "Name of the network to be created."
  type        = string
  default     = "rbac-net"
}

variable "bastion_machine_type" {
  description = "The instance size to use for your bastion instance."
  type        = string
  default     = "f1-micro"
}

variable "bastion_tags" {
  description = "A list of tags applied to your bastion instance."
  type        = list(string)
  default     = ["bastion"]
}

variable "cluster_name" {
  description = "The name to give the new Kubernetes cluster."
  type        = string
  default     = "rbac-demo-cluster"
}

variable "initial_node_count" {
  description = "The number of nodes initially provisioned in the cluster"
  type        = string
  default     = "2"
}

variable "ip_range" {
  description = "The CIDR from which to allocate cluster node IPs"
  type        = string
  default     = "10.0.96.0/22"
}

variable "master_cidr_block" {
  description = "The CIDR from which to allocate master IPs"
  type        = string
  default     = "10.0.90.0/28"
}

variable "node_machine_type" {
  description = "The instance to use for your bastion instance"
  type        = string
  default     = "n1-standard-1"
}

variable "node_tags" {
  description = "A list of tags applied to your node instances."
  type        = list(string)
  default     = ["poc"]
}

variable "secondary_ip_range" {
  // See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
  description = "The CIDR from which to allocate pod IPs for IP Aliasing."
  type        = string
  default     = "10.0.92.0/22"
}

variable "secondary_subnet_name" {
  // See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
  description = "The name to give the secondary subnet."
  type        = string
  default     = "rbac-net-secondary-sub"
}

