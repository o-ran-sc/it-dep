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

FLAVOUR=$1
MODE=$2
if [ -z "$1" ]
  then
    echo "No helm override flavour supplied, going to default"
    FLAVOUR="default"
fi

if [ -z "$2" ]
  then
    echo "No mode supplied, going to release"
    MODE="release"
fi

timestamp=$(date +%s)

TARGET_HELM_REPO="oran-snapshot" # This should be changed to oran-release once the release charts are published

if [ "$MODE" == "dev" ]; then
    TARGET_HELM_REPO="local"
elif [ "$MODE" == "snapshot" ]; then
    TARGET_HELM_REPO="oran-snapshot"
fi

echo "Starting Network Simulators namespace ..."
../sub-scripts/install-simulators.sh ../../helm-override/$FLAVOUR/network-simulators-override.yaml ../../helm-override/$FLAVOUR/network-simulators-topology-override.yaml "$TARGET_HELM_REPO"

kubectl get pods -n network
kubectl get namespaces
