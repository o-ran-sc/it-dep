#!/bin/bash
# ============LICENSE_START=======================================================
# Copyright (C) 2024-2025 OpenInfra Foundation Europe. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
#

echo  '### Installing ORAN SMO part ###'
kubectl create namespace smo

OVERRIDEYAML=$1
HELM_REPO=$2

echo "Installing SMO from HELM Repo : $HELM_REPO"
helm upgrade --install oran-smo "$HELM_REPO"/smo --namespace smo -f "$OVERRIDEYAML"  --timeout 15m

check_for_secrets() {
    try=0
    retries=60
    until (kubectl get secret -n onap | grep -P "\b$1\b") >/dev/null 2>&1; do
        try=$(($try + 1))
        [ $try -gt $retries ] && exit 1
        echo "$1 not found. Retry $try/$retries"
        sleep 10
    done
    echo "$1 found"
}

# Copying kafka secrets from onap namespace
# SMO installation uses ONAP strimzi kafka
# All KafkaUser and KafkaTopic resources should be created as part of ONAP namespace
# This enables the strimzi entity operator to create the secrets as necessary
# Once the secrets are created, it should be copied to the SMO namespace
SECRETS_SIZE=$(yq '.smo.secrets | length' "$OVERRIDEYAML")
if [ "$SECRETS_SIZE" -eq 0 ]; then
    echo "No secrets to copy from onap namespace"
    exit 0
else
    for i in $(seq 0 $((SECRETS_SIZE - 1))); do
        secret=$(yq ".smo.secrets[$i].name" "$OVERRIDEYAML")
        dependsOn=$(yq ".smo.secrets[$i].dependsOn" "$OVERRIDEYAML")
        if [ "$(yq ".$dependsOn" "$OVERRIDEYAML")" != "true" ]; then
            echo "$dependsOn is not set to true. Skipping $secret copy..."
            continue
        fi
        echo "Copying $secret from onap namespace..."
        check_for_secrets "$secret"
        kubectl get secret "$secret" -n onap -o json | jq 'del(.metadata["namespace","creationTimestamp","resourceVersion","selfLink","uid","ownerReferences"])' | kubectl apply -n smo -f -
    done
fi
