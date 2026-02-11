#!/bin/bash

###
# ============LICENSE_START=======================================================
# ORAN SMO Package
# ================================================================================
# Copyright (C) 2021 AT&T Intellectual Property. All rights
#                             reserved.
# Copyright (C) 2025 OpenInfra Foundation Europe. All rights reserved.
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
#Helm package
SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

# Check whether helm is installed and if not install it
if command -v helm > /dev/null 2>&1; then
    HELM_VERSION=$(helm version --template='{{.Version}}')
    echo "Helm ($HELM_VERSION) is already installed. Skipping installation."
else
    echo "Helm is not installed. Installing helm ..."
    cd /tmp
    wget https://get.helm.sh/helm-v3.12.3-linux-amd64.tar.gz
    tar xvfz /tmp/helm-v3.12.3-linux-amd64.tar.gz
    sudo mv linux-amd64/helm /usr/local/bin/helm
fi

echo "Checking HELM ..."
helm version

# Check whether git is installed and if not install it
if command -v git > /dev/null 2>&1; then
    echo "Git is already installed. Skipping installation."
else
    echo "Git is not installed. Installing git ..."
    sudo apt-get install git -y
fi

# Check whether helm-push is installed and if not install it
# To be compatible with helm 3 and 4 cm push needs to be
# at least in version 0.11.1
SET_VERSION=0.11.1
if helm plugin list | awk '{print $1}' | grep -w -q "cm-push"; then
    CURRENT_VERSION=$(helm plugin list | grep cm-push | awk '{print $2}')
    if [[ $(printf '%s\n' "$CURRENT_VERSION" "$SET_VERSION" | sort -V | head -n1) != "$SET_VERSION" ]]; then
        echo "Helm cm-push plugin version $CURRENT_VERSION is outdated. Uninstalling..."
        helm plugin remove cm-push
    else
        echo "Helm cm-push plugin version $CURRENT_VERSION is already installed. Skipping installation."
        SET_VERSION=""
    fi
fi

if [[ -n "$SET_VERSION" ]]; then
    echo "Installing helm cm-push plugin version $SET_VERSION..."
    TAR_FILE=helm-push_${SET_VERSION}_darwin_amd64.tar.gz
    HELM_PLUGINS=$(helm env HELM_PLUGINS)
    mkdir -p $HELM_PLUGINS/helm-push
    cd $HELM_PLUGINS/helm-push
    # It would be better to do this download through nexus. Sometimes, we can find that
    # wget and curl fail when pulling from github
    wget https://github.com/chartmuseum/helm-push/releases/download/v$SET_VERSION/$TAR_FILE
    tar zxvf $TAR_FILE >/dev/null
    rm $TAR_FILE
fi

# Check whether make is installed and if not install it
if command -v make > /dev/null 2>&1; then
    echo "Make is already installed. Skipping installation."
else
    echo "Make is not installed. Installing make ..."
    sudo apt-get install make -y
fi

cd $SCRIPT_PATH
# Check whether undeploy and deploy plugins are installed by comparing exact name and if not install them
if helm plugin list | awk '{print $1}' | grep -w -q "undeploy"; then
    echo "Helm undeploy plugin is already installed. Skipping installation."
else
    echo "Helm undeploy plugin is not installed. Installing undeploy plugin ..."
    helm plugin install ../../onap_oom/kubernetes/helm/plugins/undeploy/
fi
if helm plugin list | awk '{print $1}' | grep -w -q "deploy"; then
    echo "Helm deploy plugin is already installed. Skipping installation."
else
    echo "Helm deploy plugin is not installed. Installing deploy plugin ..."
    helm plugin install ../../onap_oom/kubernetes/helm/plugins/deploy/
fi

helm repo add oran-snapshot https://nexus3.o-ran-sc.org/repository/helm.snapshot/
helm repo add oran-release https://nexus3.o-ran-sc.org/repository/helm.release/
helm repo add strimzi https://strimzi.io/charts/
helm repo add openebs https://openebs.github.io/openebs
helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator
helm repo update