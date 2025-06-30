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

if ! command -v yq > /dev/null 2>&1; then
    ARCH=$(case $(uname -m) in x86_64) echo "amd64";; aarch64) echo "arm64";; *) uname -m;; esac)
    VERSION="v4.45.4"
    echo "yq is not installed. Installing yq..."
    sudo wget https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_${ARCH} -O /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
fi

if ! command -v jq > /dev/null 2>&1; then
    echo "jq is not installed. Installing jq..."
    sudo apt-get install jq -y
fi

# OpenEBS installation
helm repo add openebs https://openebs.github.io/openebs
helm repo update
helm upgrade --install openebs --namespace openebs openebs/openebs --version 4.3.0 --create-namespace --set engines.replicated.mayastor.enabled=false --set engines.local.lvm.enabled=false --set engines.local.zfs.enabled=false --set loki.enabled=false --set alloy.enabled=false --wait

# Create storage class for smo
kubectl apply -f ../packages/pre-configuration/smo-sc.yaml

# Mariadb operator installation
kubectl create ns mariadb-operator
helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator
helm repo update
helm upgrade --install mariadb-operator-crds mariadb-operator/mariadb-operator-crds -n mariadb-operator
helm upgrade --install mariadb-operator mariadb-operator/mariadb-operator -n mariadb-operator
kubectl wait deployment mariadb-operator -n mariadb-operator --for=condition=available --timeout=120s
