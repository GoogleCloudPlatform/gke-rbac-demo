# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SHELL := /usr/bin/env bash

.PHONY: ci
ci: verify-header

.PHONY: verify-header
verify-header:
	python test/verify_boilerplate.py
	@echo "\n Test passed - Verified all file Apache 2 headers"

.PHONY: setup-project
setup-project:
	# Enables the Google Cloud APIs needed
	./enable-apis.sh
	# Runs the generate-tfvars.sh
	./generate-tfvars.sh

.PHONY: tf-apply
tf-apply:
	# Downloads the terraform providers and applies the configuration
	cd terraform && terraform init && terraform apply

.PHONY: tf-destroy
tf-destroy:
	# Downloads the terraform providers and applies the configuration
	cd terraform && terraform destroy
