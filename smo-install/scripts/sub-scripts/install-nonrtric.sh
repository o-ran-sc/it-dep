#!/bin/bash

###
# ============LICENSE_START========================================================
# ORAN SMO Package
# =================================================================================
# Copyright (C) 2021 AT&T Intellectual Property. All rights reserved.
# Modification Copyright (C) 2024 OpenInfra Foundation Europe. All rights reserved.
# =================================================================================
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
# ============LICENSE_END==========================================================
# =================================================================================
#
###

kubectl create namespace nonrtric
echo  '### Installing ORAN NONRTRIC part ###'

OVERRIDEYAML="../../helm-override/default/oran-override.yaml"

if ! command -v yq > /dev/null 2>&1; then
    echo "yq is not installed. Installing yq..."
    sudo snap install yq --channel=v3/stable
fi

INSTALL_KONG=$(yq read "$OVERRIDEYAML" 'nonrtric.installKong')
if [ $? -ne 0 ] || [ -z "$INSTALL_KONG"  ]; then
    echo "Error: failed to parse installKong from YAML with yq. Aborting install."
    exit 1
fi

INSTALL_CAPIF=$(yq read "$OVERRIDEYAML" 'nonrtric.installCapifcore')
if [ $? -ne 0 ] || [ -z "$INSTALL_CAPIF"  ]; then
    echo "Error: failed to parse installCapifcore from YAML with yq. Aborting install."
    exit 1
fi

INSTALL_SERVICEMANAGER=$(yq read "$OVERRIDEYAML" 'nonrtric.installServicemanager')
if [ $? -ne 0 ] || [ -z "$INSTALL_SERVICEMANAGER"  ]; then
    echo "Error: failed to parse installServicemanager from YAML with yq. Aborting install."
    exit 1
fi

if [ "$INSTALL_SERVICEMANAGER" == "true" ]; then
    if [ "$INSTALL_CAPIF" == "false" ]; then
        echo "Error: INSTALL_CAPIF must be true if INSTALL_SERVICEMANAGER is true. Aborting install."
        exit 1
    fi
    if [ "$INSTALL_KONG" == "false" ]; then
        echo "Error: INSTALL_KONG must be true if INSTALL_SERVICEMANAGER is true. Aborting install."
        exit 1
    fi
    echo "INSTALL_SERVICEMANAGER, INSTALL_CAPIF and INSTALL_KONG are true. Proceeding with installation of Service Manager, Capifcore and Kong."
fi

helm install --debug oran-nonrtric local/nonrtric --namespace nonrtric -f $1 --set nonrtric.persistence.mountPath="/dockerdata-nfs/deployment-$2"
