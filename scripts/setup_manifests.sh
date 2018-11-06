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

owner "source /etc/profile && exit"
auditor "source /etc/profile && exit"
admin "source /etc/profile && exit"
admin "kubectl apply -n default -f ./manifests/rbac.yaml"

owner "kubectl apply -n dev -f ./manifests/hello-server.yaml"
owner "kubectl apply -n prod -f ./manifests/hello-server.yaml"
owner "kubectl apply -n test -f ./manifests/hello-server.yaml"

admin "kubectl apply -n default -f manifests/pod-labeler.yaml"
admin "kubectl apply -n default -f manifests/pod-labeler-fix-2.yaml"

sleep 15
