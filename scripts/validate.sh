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

# bash "strict-mode", fail immediately if there is a problem
set -o nounset
set -o pipefail

SUCCESS="hello-server-"
FAILURE="Error from server (Forbidden)"
PODLABELER="pod-labeler-"

source "./scripts/common.sh"

source "./scripts/setup_manifests.sh"

# OWNER Tests
echo "--- Owner Tests ---"
owner "kubectl get pods -n dev" | grep "$SUCCESS" &> /dev/null || exit 1
echo "Step 1 of the validation passed."
owner "kubectl get pods -n test" | grep "$SUCCESS" &> /dev/null || exit 1
echo "Step 2 of the validation passed."
owner "kubectl get pods -n prod" | grep "$SUCCESS" &> /dev/null || exit 1
echo "Step 3 of the validation passed."

# AUDITOR Tests
echo "--- Auditor Tests ---"
auditor "kubectl get pods -l app=hello-server --all-namespaces" | grep "$FAILURE" &> /dev/null || exit 1
echo "Step 4 of the validation passed."
auditor "kubectl get pods -n test" | grep "$FAILURE" &> /dev/null || exit 1
echo "Step 5 of the validation passed."
auditor "kubectl get pods -n prod" | grep "$FAILURE" &> /dev/null || exit 1
echo "Step 6 of the validation passed."
auditor "kubectl run shell -i --tty --image alpine:3.7 -- sh" | grep "$FAILURE" &> \
/dev/null || exit 1
echo "Step 7 of the validation passed."
auditor "kubectl delete pod foo-x123" | grep "$FAILURE" &> /dev/null || exit 1
echo "Step 8 of the validation passed."

# ADMIN Tests
echo "--- Admin Tests ---"
admin "kubectl get pods -l app=pod-labeler" | grep "$PODLABELER" &> /dev/null || exit 1
echo "Step 9 of the validation passed."
