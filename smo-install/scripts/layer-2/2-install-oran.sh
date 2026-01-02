#!/bin/bash

###
# ============LICENSE_START=======================================================
# ORAN SMO Package
# ================================================================================
# Copyright (C) 2021 AT&T Intellectual Property. All rights
#                             reserved.
# Modification Copyright (C) 2024-2026 OpenInfra Foundation Europe. All rights reserved.
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
IS_GENERATED_ONAP_OVERRIDE=false
IS_GENERATED_ORAN_OVERRIDE=false

if ! command -v yq > /dev/null 2>&1; then
    ARCH=$(case $(uname -m) in x86_64) echo "amd64";; aarch64) echo "arm64";; *) uname -m;; esac)
    VERSION="v4.45.4"
    echo "yq is not installed. Installing yq..."
    sudo wget https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_${ARCH} -O /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
fi

FLAVOUR=$1
MODE=$2
if [ -z "$1" ]
  then
    echo "No helm override flavour supplied, going to default"
    FLAVOUR="default"
  elif [ "$1" = "default" ]
  then
    echo "Using helm override flavour: $FLAVOUR"
  else
    echo "Using helm override flavour: $FLAVOUR"
    if [ -f "../../helm-override/$FLAVOUR/onap-flavour-config.yaml" ]; then
      echo -e "\e[33mPlease ensure that the helm-override/$FLAVOUR onap override config file contains a kubernetes participant entry to add your helm repository to the whitelist.\e[0m"
      echo "Generating onap-override.yaml for flavour $FLAVOUR"
      yq eval-all '. as $item ireduce ({}; . * $item )' ../../helm-override/default/onap-override.yaml ../../helm-override/$FLAVOUR/onap-flavour-config.yaml > ../../helm-override/$FLAVOUR/onap-override.yaml
      IS_GENERATED_ONAP_OVERRIDE=true
    else
      echo "No onap-flavour-config.yaml found for flavour $FLAVOUR."
      exit 1
    fi

    if [ -f "../../helm-override/$FLAVOUR/oran-flavour-config.yaml" ]; then
      echo "Generating oran-override.yaml for flavour $FLAVOUR"
      yq eval-all '. as $item ireduce ({}; . * $item ) ' ../../helm-override/default/oran-override.yaml ../../helm-override/$FLAVOUR/oran-flavour-config.yaml > ../../helm-override/$FLAVOUR/oran-override.yaml
      IS_GENERATED_ORAN_OVERRIDE=true
    else
      echo "No oran-flavour-config.yaml found for flavour $FLAVOUR."
      exit 1
    fi
fi

if [ -z "$2" ]
  then
    echo "No mode supplied, going to release"
    MODE="release"
fi

timestamp=$(date +%s)

TARGET_HELM_REPO="oran-release"

if [ "$MODE" == "dev" ]; then
    helm cm-push ../packages/strimzi-kafka-operator-helm-3-chart-0.45.0.tgz local
    helm repo update
    TARGET_HELM_REPO="local"
elif [ "$MODE" == "snapshot" ]; then
    TARGET_HELM_REPO="oran-snapshot"
fi

echo "Pre configuring SMO ..."
../sub-scripts/preconfigure-smo.sh ../../helm-override/"$FLAVOUR"/onap-override.yaml
echo "SMO pre configuration done."

echo "Starting ONAP & NONRTRIC namespaces ..."
../sub-scripts/install-onap.sh ../../helm-override/"$FLAVOUR"/onap-override.yaml "$TARGET_HELM_REPO" "$timestamp"
../sub-scripts/install-nonrtric.sh ../../helm-override/"$FLAVOUR"/oran-override.yaml "$TARGET_HELM_REPO" "$timestamp"
../sub-scripts/install-smo.sh ../../helm-override/"$FLAVOUR"/oran-override.yaml "$TARGET_HELM_REPO" "$timestamp"

echo "Starting SMO Post Configuration ..."
../sub-scripts/postconfigure-smo.sh ../../helm-override/"$FLAVOUR"/oran-override.yaml
echo "SMO post configuration done."

kubectl get pods -n onap
kubectl get pods -n nonrtric
kubectl get pods -n smo
kubectl get namespaces

if [ "$IS_GENERATED_ONAP_OVERRIDE" = true ]; then
  rm -f ../../helm-override/"$FLAVOUR"/onap-override.yaml
fi
if [ "$IS_GENERATED_ORAN_OVERRIDE" = true ]; then
  rm -f ../../helm-override/"$FLAVOUR"/oran-override.yaml
fi

echo "SMO Installation completed successfully in $(( ($(date +%s) - $timestamp) / 60 )) minutes."
