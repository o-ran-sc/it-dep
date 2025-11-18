#!/bin/bash
# ============LICENSE_START=======================================================
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
#

if ! command -v jq > /dev/null 2>&1; then
    echo "jq is not installed. Installing jq..."
    ARCH=$(case $(uname -m) in x86_64) echo "amd64";; aarch64) echo "arm64";; *) uname -m;; esac)
    VERSION="1.8.1"
    echo "jq is not installed. Installing jq..."
    sudo wget https://github.com/jqlang/jq/releases/download/jq-${VERSION}/jq-linux-${ARCH} -O /usr/local/bin/jq
    sudo chmod +x /usr/local/bin/jq
fi

OVERRIDEYAML=$1
NEXUS_PROXY_DOCKER_IO_REPO="nexus3.o-ran-sc.org:10001"

# OpenEBS installation
helm upgrade --install openebs --namespace openebs openebs/openebs --version 4.3.0 --create-namespace --set engines.replicated.mayastor.enabled=false --set engines.local.lvm.enabled=false --set engines.local.zfs.enabled=false --set loki.enabled=false --set alloy.enabled=false --set global.imageRegistry=$NEXUS_PROXY_DOCKER_IO_REPO --set preUpgradeHook.image.registry=$NEXUS_PROXY_DOCKER_IO_REPO --set preUpgradeHook.image.repo=bitnamilegacy/kubectl &

# Create storage class for smo
kubectl apply -f ../packages/pre-configuration/smo-sc.yaml

INSTALL_MARIADB=$(cat $OVERRIDEYAML | yq e '.mariadb-galera.enabled' -)
if [ $? -ne 0 ] || [ -z "$INSTALL_MARIADB"  ]; then
    echo "Error: failed to parse INSTALL_MARIADB from YAML with yq. Aborting install."
    exit 1
fi
if [ "$INSTALL_MARIADB" == "true" ]; then
    echo "Installing MariaDB operator..."
    # Mariadb operator installation
    kubectl create ns mariadb-operator
    helm upgrade --install mariadb-operator-crds mariadb-operator/mariadb-operator-crds -n mariadb-operator &
    helm upgrade --install mariadb-operator mariadb-operator/mariadb-operator -n mariadb-operator &
else
    echo "Skipping MariaDB operator installation as per configuration."
fi

