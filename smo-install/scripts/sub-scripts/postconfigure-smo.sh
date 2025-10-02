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

# Configure service manager with the installed services

OVERRIDEYAML=$1

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

if [ "$INSTALL_SERVICEMANAGER" == "true" ]; then
    echo "Waiting for capifcore deployment"
    kubectl wait --for=condition=Available -n nonrtric --timeout=300s deploy/capifcore

    echo "Waiting for servicemanager deployment"
    kubectl wait --for=condition=Available -n nonrtric --timeout=300s deploy/servicemanager

    echo "Waiting for kong deployment"
    kubectl wait --for=condition=Available -n nonrtric --timeout=300s deploy/oran-nonrtric-kong
    # Send stderr to /dev/null to turn off chatty logging
    ../sub-scripts/servicemanager-preload.sh ../packages/post-configuration/servicemanager-preconfig-nonrtric.yaml 2>/dev/null
    ../sub-scripts/servicemanager-preload.sh ../packages/post-configuration/servicemanager-preconfig-smo.yaml 2>/dev/null
fi
