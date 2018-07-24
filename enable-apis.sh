#!/usr/bin/env bash

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



# Stop immediately if something goes wrong
set -euo pipefail

# Validate the user would like to proceed
echo
echo "The following APIs will be enabled in your Google Cloud account:"
echo "- compute.googleapis.com"
echo "- container.googleapis.com"
echo "- cloudbuild.googleapis.com"
echo
read -p "Would you like to proceed? [y/n]: " -n 1 -r
echo
# Require a "Y" or "y" to proceed. Otherwise abort.
if [[ ! "$REPLY" =~ ^[Yy]$ ]]
then
    # Do not continue. Do not enable the APIs.
    echo "Exiting without making changes."
    exit 1
fi

# Enable Compute Engine, Kubernetes Engine, and Container Builder
echo "Enabling the Compute API"
gcloud services enable compute.googleapis.com
echo "Enabling the Container API."
gcloud services enable container.googleapis.com
echo "Enabling the Cloud Build API."
gcloud services enable cloudbuild.googleapis.com
echo "APIs enabled successfully."
