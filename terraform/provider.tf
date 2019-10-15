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

// Configures the default project and zone for underlying Google Cloud API calls
provider "google" {
  project = var.project
  zone    = var.zone
  version = "~> 2.17.0"
}

// Pins the version of the "random" provider
provider "random" {
  version = "~> 2.1.2"
}

// Pins the version of the "template" provider
provider "template" {
  version = "~> 2.1.2"
}

// Pins the version of the "null" provider
provider "null" {
  version = "~> 2.1.2"
}

