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
HELM_REPO=$2

INSTALL_STRIMZI=$(cat $OVERRIDEYAML | yq e '.strimzi.enabled' -)
if [ $? -ne 0 ] || [ -z "$INSTALL_STRIMZI"  ]; then
    echo "Error: failed to parse INSTALL_STRIMZI from YAML with yq. Aborting install."
    exit 1
fi

if [ "$INSTALL_STRIMZI" == "true" ]; then
  STRIMZI_HELM_REPO="local"
  if [ "$HELM_REPO" != "local" ]; then
    STRIMZI_HELM_REPO="strimzi"
  fi

  echo "### Installing Strimzi Kafka Operator (From Helm repo $STRIMZI_HELM_REPO) ###"
  helm upgrade --install strimzi-kafka-operator "$STRIMZI_HELM_REPO"/strimzi-kafka-operator --namespace strimzi-system --version 0.45.0 --set watchAnyNamespace=true --create-namespace &
fi

kubectl create namespace onap
echo "### Installing ONAP part (From Helm repo $HELM_REPO) ###"
helm deploy --debug onap "$HELM_REPO"/onap --namespace onap -f $1 --create-namespace