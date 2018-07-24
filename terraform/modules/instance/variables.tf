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

variable "hostname" {
  description = "the hostname"
  type        = "string"
}

variable "machine_type" {
  description = "the instance type"
  type        = "string"
}

variable "project" {
  description = "the project for this instance"
  type        = "string"
}

variable "zone" {
  description = "the desired zone for the host"
  type        = "string"
}

variable "tags" {
  description = "the instance tags"
  type        = "list"
}

variable "cluster_subnet" {
  description = "the subnet in which to put the private IP address"
  type        = "string"
}

variable "cluster_name" {
  description = "the name of the cluster for which this host will be used to connect"
  type        = "string"
}

variable "owner_email" {
  description = "email of a test account to which to grant read-write privileges via RBAC"
  type        = "string"
}

variable "auditor_email" {
  description = "email of a test account to which to grant read-only privileges via RBAC"
  type        = "string"
}

variable "service_account_email" {
  description = ""
  type        = "string"
  default     = ""
}

variable "grant_cluster_admin" {
  description = ""
  type        = "string"
  default     = "0"
}

variable "vpc_name" {
  type    = "string"
  default = "kube-net"
}
