#!/bin/bash

###
# ============LICENSE_START========================================================
# ORAN SMO Package
# =================================================================================
# Copyright (C) 2021 AT&T Intellectual Property. All rights reserved.
# Modification Copyright (C) 2024-2025 OpenInfra Foundation Europe. All rights reserved.
# =================================================================================
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
# ============LICENSE_END==========================================================
# =================================================================================
#
###

kubectl create namespace nonrtric
echo  '### Installing ORAN NONRTRIC part ###'

OVERRIDEYAML=$1

if ! command -v yq > /dev/null 2>&1; then
    wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq &&\
    chmod +x /usr/local/bin/yq
fi

MODE=$2

defaultSc=$(kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')
kongPvEnabled=true
if [ -n "$defaultSc" ]; then
    echo "Default storage is set to : $defaultSc. Setting kong.kongpv.enable to false"
    kongPvEnabled=false
fi


if [ "$MODE" == "dev" ]; then
    echo "Installing NONRTRIC in dev mode"
    helm upgrade --install --debug oran-nonrtric local/nonrtric --namespace nonrtric -f $OVERRIDEYAML --set nonrtric.persistence.mountPath="/dockerdata-nfs/deployment-$3" --set kong.kongpv.enabled=$kongPvEnabled
else
    echo "Installing NONRTRIC in release mode"
    # This following should be modified once the charts are uploaded and available in the nexus repository
    # Till then, we are using the local chart
        # helm repo add nonrtric https://nexus3.o-ran-sc.org/repository/smo-helm-snapshots/
        # helm repo update
        # helm install oran-nonrtric nonrtric/nonrtric --namespace nonrtric -f $OVERRIDEYAML --create-namespace
    helm upgrade --install oran-nonrtric local/nonrtric --namespace nonrtric -f $OVERRIDEYAML --set nonrtric.persistence.mountPath="/dockerdata-nfs/deployment-$3" --set kong.kongpv.enabled=$kongPvEnabled
fi


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
SECRETS_SIZE=$(yq '.nonrtric.secrets | length' $OVERRIDEYAML)
if [ "$SECRETS_SIZE" -eq 0 ]; then
    echo "No secrets to copy from onap namespace"
    exit 0
else
    for i in $(seq 0 $((SECRETS_SIZE - 1))); do
        secret=$(yq ".nonrtric.secrets[$i].name" $OVERRIDEYAML)
        dependsOn=$(yq ".nonrtric.secrets[$i].dependsOn" $OVERRIDEYAML)
        if [ $(yq ".$dependsOn" $OVERRIDEYAML) != "true" ]; then
            echo "$dependsOn is not set to true. Skipping $secret copy..."
            continue
        fi
        echo "Copying $secret from onap namespace..."
        check_for_secrets $secret
        kubectl get secret $secret -n onap -o json | jq 'del(.metadata["namespace","creationTimestamp","resourceVersion","selfLink","uid","ownerReferences"])' | kubectl apply -n nonrtric -f -
    done
fi
