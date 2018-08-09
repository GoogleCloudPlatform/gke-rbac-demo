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
set -euo pipefail

SUCCESS="hello-server-"
FAILURE="Error from server (Forbidden)"
UPDATED="updated="
OUTPUT=$SUCCESS

#auditor() {
#  local command=$1; shift;
#  echo $(gcloud compute ssh gke-tutorial-auditor --command "${command}")
#}
#auditor ""
# TEST CASES:
#a) confirming that the "owner" can create/view all resources - X
#b) confirming that the "auditor" cannot list all pods, but CAN list pods in the dev namespace - X
#c) confirming that the "auditor" cannot create or delete pods - X
#d) deploying the pod-labeler application and confirming the labels appear on the pods - 
#e) Makefile needs validate target

owner() {
  local command=$1; shift;
  echo "$(gcloud compute ssh gke-tutorial-owner --command "${command}" 2>&1)"
}
admin() {
  local command=$1; shift;
  echo "$(gcloud compute ssh gke-tutorial-admin --command "${command}" 2>&1)"
}
auditor() {
  local command=$1; shift;
  echo "$(gcloud compute ssh gke-tutorial-auditor --command "${command}" 2>&1)"
}


# OWNER
owner "kubectl get pods -n dev" | grep "$OUTPUT" &> /dev/null || exit 1
echo "step 1 of the validation passed."
owner "kubectl get pods -n test" | grep "$OUTPUT" &> /dev/null || exit 1
echo "step 2 of the validation passed."
owner "kubectl get pods -n prod" | grep "$OUTPUT" &> /dev/null || exit 1
echo "step 3 of the validation passed."

# AUDITOR
auditor "kubectl get pods -n dev" | grep "$OUTPUT" &> /dev/null || exit 1
echo "step 4 of the validation passed."

OUTPUT=$FAILURE
auditor "kubectl get pods -n test" | grep "$OUTPUT" &> /dev/null || exit 1
echo "step 5 of the validation passed."
auditor "kubectl get pods -n prod" | grep "$OUTPUT" &> /dev/null || exit 1
echo "step 6 of the validation passed."

auditor "kubectl run shell -i --tty --image alpine:3.7 -- sh" | grep "$OUTPUT" &> \
/dev/null || exit 1
echo "step 7 of the validation passed."
auditor "kubectl delete pod foo-x123" | grep "$OUTPUT" &> /dev/null || exit 1
echo "step 8 of the validation passed."

OUTPUT=$UPDATED
admin "kubectl get pods --show-labels" | grep "$OUTPUT" &> /dev/null || exit 1
echo "step 9 of the validation passed." 