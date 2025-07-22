#!/bin/bash

###
# ============LICENSE_START=======================================================
# ORAN SMO Package
# ================================================================================
# Copyright (C) 2021 AT&T Intellectual Property. All rights
#                             reserved.
# Modification Copyright (C) 2024-2025 OpenInfra Foundation Europe. All rights reserved.
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

echo "Pre configuring SMO ..."
../sub-scripts/preconfigure-smo.sh ../../helm-override/$FLAVOUR/oran-override.yaml $MODE $timestamp
echo "SMO pre configuration done."

echo "Starting ONAP & NONRTRIC namespaces ..."
../sub-scripts/install-onap.sh ../../helm-override/$FLAVOUR/onap-override.yaml $MODE $timestamp
../sub-scripts/install-nonrtric.sh ../../helm-override/$FLAVOUR/oran-override.yaml $MODE $timestamp
../sub-scripts/install-smo.sh ../../helm-override/$FLAVOUR/oran-override.yaml $MODE $timestamp

echo "Starting SMO Post Configuration ..."
../sub-scripts/postconfigure-smo.sh ../../helm-override/$FLAVOUR/oran-override.yaml $MODE $timestamp
echo "SMO post configuration done."

kubectl get pods -n onap
kubectl get pods -n nonrtric
kubectl get pods -n smo
kubectl get namespaces

echo "SMO Installation completed successfully in $(( ($(date +%s) - $timestamp) / 60 )) minutes."
