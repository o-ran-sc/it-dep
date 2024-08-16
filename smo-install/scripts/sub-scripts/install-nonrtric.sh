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

OVERRIDEYAML=$1

if ! command -v yq > /dev/null 2>&1; then
    echo "yq is not installed. Installing yq..."
    sudo snap install yq --channel=v4/stable
fi

INSTALL_KONG=$(cat $OVERRIDEYAML | yq e '.nonrtric.installKong' -)
if [ $? -ne 0 ] || [ -z "$INSTALL_KONG"  ]; then
    echo "Error: failed to parse installKong from YAML with yq. Aborting install."
    exit 1
fi

INSTALL_CAPIF=$(cat $OVERRIDEYAML | yq e '.nonrtric.installCapifcore' -)
if [ $? -ne 0 ] || [ -z "$INSTALL_CAPIF"  ]; then
    echo "Error: failed to parse installCapifcore from YAML with yq. Aborting install."
    exit 1
fi

INSTALL_SERVICEMANAGER=$(cat $OVERRIDEYAML | yq e '.nonrtric.installServicemanager' -)
if [ $? -ne 0 ] || [ -z "$INSTALL_SERVICEMANAGER"  ]; then
    echo "Error: failed to parse installServicemanager from YAML with yq. Aborting install."
    exit 1
fi

if [ "$INSTALL_SERVICEMANAGER" == "true" ]; then
    if [ "$INSTALL_KONG" == "false" ]; then
        echo "Error: INSTALL_KONG must be true if INSTALL_SERVICEMANAGER is true. Aborting install."
        exit 1
    fi
    if [ "$INSTALL_CAPIF" == "false" ]; then
        echo "Error: INSTALL_CAPIF must be true if INSTALL_SERVICEMANAGER is true. Aborting install."
        exit 1
    fi
fi

helm install --debug oran-nonrtric local/nonrtric --namespace nonrtric -f $OVERRIDEYAML --set nonrtric.persistence.mountPath="/dockerdata-nfs/deployment-$2"

if [ "$INSTALL_SERVICEMANAGER" == "true" ]; then
    pushd ../../../servicemanager-preload
    # Send stderr to null to turn off chatty logging
    cat config-nonrtric.yaml config-smo.yaml > config-nonrtric-smo.yaml
    ./servicemanager-preload.sh config-nonrtric-smo.yaml 2>/dev/null
    rm -v config-nonrtric-smo.yaml
    popd
fi
