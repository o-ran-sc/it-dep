#!/bin/bash

###
# ============LICENSE_START=======================================================
# ORAN SMO Package
# ================================================================================
# Copyright (C) 2021 AT&T Intellectual Property. All rights
#                             reserved.
# Modification Copyright (C) 2025 OpenInfra Foundation Europe. All rights reserved.
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
# ===================================================================
# 
###

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
cd $SCRIPT_PATH

OVERRIDEYAML=$1
MODE=$2

INSTALL_STRIMZI=$(cat $OVERRIDEYAML | yq e '.strimzi.enabled' -)
if [ $? -ne 0 ] || [ -z "$INSTALL_STRIMZI"  ]; then
    echo "Error: failed to parse INSTALL_STRIMZI from YAML with yq. Aborting install."
    exit 1
fi

if [ "$MODE" == "dev" ]; then
    if [ "$INSTALL_STRIMZI" == "true" ]; then
        echo "### Installing Strimzi Kafka Operator (Dev Mode) ###"
        helm cm-push ../packages/strimzi-kafka-operator-helm-3-chart-0.45.0.tgz local
        helm repo update
        helm upgrade --install strimzi-kafka-operator local/strimzi-kafka-operator --namespace strimzi-system --version 0.45.0 --set watchAnyNamespace=true --create-namespace
        echo "Waiting for Strimzi Kafka Operator to be ready..."
        kubectl wait --for=condition=available --timeout=600s deployment/strimzi-cluster-operator -n strimzi-system
    fi

    kubectl create namespace onap
    echo '### Installing ONAP part (Dev Mode) ###'
    helm deploy --debug onap local/onap --namespace onap -f $1
else
    if [ "$INSTALL_STRIMZI" == "true" ]; then
        echo "### Installing Strimzi Kafka Operator (Release Mode) ###"
        helm repo add strimzi https://strimzi.io/charts/
        helm repo update
        helm upgrade --install strimzi-kafka-operator strimzi/strimzi-kafka-operator --namespace strimzi-system --version 0.45.0 --set watchAnyNamespace=true --create-namespace
        echo "Waiting for Strimzi Kafka Operator to be ready..."
        kubectl wait --for=condition=available --timeout=600s deployment/strimzi-cluster-operator -n strimzi-system
    fi

    echo '### Installing ONAP part (Release Mode) ###'
    helm repo add onap https://nexus3.onap.org/repository/onap-helm-testing/
    helm repo update

    helm deploy --debug onap onap/onap --namespace onap -f $1 --create-namespace
fi