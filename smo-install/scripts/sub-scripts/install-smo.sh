#!/bin/bash
# ============LICENSE_START=======================================================
# Copyright (C) 2024 OpenInfra Foundation Europe. All rights reserved.
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

helm install --debug oran-smo local/smo --namespace smo -f $OVERRIDEYAML

# Copying kafka secrets from onap namespace
# SMO installation uses ONAP strimzi kafka
# All KafkaUser and KafkaTopic resources should be created as part of ONAP namespace
# This enables the strimzi entity operator to create the secrets as necessary
# Once the secrets are created, it should be copied to the SMO namespace
while IFS= read -r secret; do
    echo "Copying $secret from onap namespace..."
    kubectl get secret $secret -n onap -o json | jq 'del(.metadata["namespace","creationTimestamp","resourceVersion","selfLink","uid","ownerReferences"])' | kubectl apply -n smo -f -
done < <(yq r -d0 $OVERRIDEYAML smo.secrets[*])