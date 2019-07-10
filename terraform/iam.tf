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
Defines a random string to use as our role name suffix to ensure uniqueness.

See https://www.terraform.io/docs/providers/random/r/string.html
*/
resource "random_string" "role_suffix" {
  length  = 8
  special = false
}

/*
Define a read-only role for API access

See https://www.terraform.io/docs/providers/google/r/google_project_iam_custom_role.html
*/
resource "google_project_iam_custom_role" "kube-api-ro" {
  // Randomize the name to avoid collisions with deleted roles
  // (Deleted roles prevent similarly named roles from being created for up to 30 days)
  // See https://cloud.google.com/iam/docs/creating-custom-roles#deleting_a_custom_role
  role_id = "kube_api_ro_${random_string.role_suffix.result}"

  title       = "Kubernetes API (RO)"
  description = "Grants read-only API access that can be further restricted with RBAC"

  permissions = [
    "container.apiServices.get",
    "container.apiServices.list",
    "container.clusters.get",
    "container.clusters.getCredentials",
  ]
}

resource "google_service_account" "owner" {
  account_id   = "gke-tutorial-owner-rbac"
  display_name = "GKE Tutorial Owner RBAC"
}

resource "google_service_account" "auditor" {
  account_id   = "gke-tutorial-auditor-rbac"
  display_name = "GKE Tutorial Auditor RBAC"
}

resource "google_service_account" "admin" {
  account_id   = "gke-tutorial-admin-rbac"
  display_name = "GKE Tutorial Admin RBAC"
}

resource "google_project_iam_binding" "kube-api-ro" {
  role = "projects/${var.project}/roles/${google_project_iam_custom_role.kube-api-ro.role_id}"

  members = [
    "serviceAccount:${google_service_account.owner.email}",
    "serviceAccount:${google_service_account.auditor.email}",
  ]
}

resource "google_project_iam_member" "kube-api-admin" {
  project = var.project
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.admin.email}"
}

