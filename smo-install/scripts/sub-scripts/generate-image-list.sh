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

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

NEXUS_PROXY_DOCKER_IO_REPO="nexus3.o-ran-sc.org:10001"

HELM_REPO=$1
if [ -z "$HELM_REPO" ]; then
  HELM_REPO="oran-snapshot"
fi

echo "Generating image list from Helm charts in repo: $HELM_REPO ..."
ONAP_HELM_IMAGES=$(helm template onap-app "$HELM_REPO"/onap -f $SCRIPT_PATH/../../helm-override/default/onap-override.yaml | grep -v "^\s*#" | awk -F'image: ' '/image:/ {gsub(/["'\'']/, "", $2); print $2}' | sort -u)
echo "ONAP images extracted from Helm charts: $(echo "$ONAP_HELM_IMAGES" | wc -l)"

NONRTRIC_HELM_IMAGES=$(helm template nonrtric-app "$HELM_REPO"/nonrtric -f $SCRIPT_PATH/../../helm-override/default/oran-override.yaml | grep -v "^\s*#" | awk -F'image: ' '/image:/ {gsub(/["'\'']/, "", $2); print $2}' | sort -u)
echo "NONRTRIC images extracted from Helm charts: $(echo "$NONRTRIC_HELM_IMAGES" | wc -l)"

SMO_HELM_IMAGES=$(helm template smo-app "$HELM_REPO"/smo -f $SCRIPT_PATH/../../helm-override/default/oran-override.yaml | grep -v "^\s*#" | awk -F'image: ' '/image:/ {gsub(/["'\'']/, "", $2); print $2}' | sort -u)
echo "SMO images extracted from Helm charts: $(echo "$SMO_HELM_IMAGES" | wc -l)"

OPENEBS_IMAGES=$(helm template openebs openebs/openebs --version 4.3.0 --create-namespace --set engines.replicated.mayastor.enabled=false --set engines.local.lvm.enabled=false --set engines.local.zfs.enabled=false --set loki.enabled=false --set alloy.enabled=false --set global.imageRegistry=$NEXUS_PROXY_DOCKER_IO_REPO --set preUpgradeHook.image.registry=$NEXUS_PROXY_DOCKER_IO_REPO --set preUpgradeHook.image.repo=bitnamilegacy/kubectl | grep -v "^\s*#" | awk -F'image: ' '/image:/ {gsub(/["'\'']/, "", $2); print $2}' | sort -u)
echo "OpenEBS images extracted from Helm charts: $(echo "$OPENEBS_IMAGES" | wc -l)"

MARIADB_OPERATOR_IMAGES=$(helm template mariadb-operator mariadb-operator/mariadb-operator | grep -v "^\s*#" | awk -F'image: ' '/image:/ {gsub(/["'\'']/, "", $2); print $2}' | sort -u)
echo "MariaDB Operator images extracted from Helm charts: $(echo "$MARIADB_OPERATOR_IMAGES" | wc -l)"

echo -e "\n------- Unique Image List -------"
{
    echo "$ONAP_HELM_IMAGES"
    echo "$NONRTRIC_HELM_IMAGES"
    echo "$SMO_HELM_IMAGES"
    echo "$MARIADB_OPERATOR_IMAGES"
    echo "$OPENEBS_IMAGES"
} | sort -u
