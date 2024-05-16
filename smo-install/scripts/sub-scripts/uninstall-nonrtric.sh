#!/bin/bash

###
# ============LICENSE_START========================================================
# ORAN SMO Package
# =================================================================================
# Copyright (C) 2021 AT&T Intellectual Property. All rights
#                             reserved.
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

if ! jq --version > /dev/null 2>&1 ; then
    sudo apt-get update
    sudo apt-get install -y jq
fi

INSTALL_KONG=$(helm get values oran-nonrtric -n nonrtric -o json | jq '.nonrtric.installKong')
if [ $? -ne 0 ]; then
    echo "Failed to parse helm release value installKong with jq."
    exit 1
fi

if [ "$INSTALL_KONG" = true ];then
    echo "Warning - deleting Kong routes and services for ServiceManager."
    SERVICEMANAGER_POD=$(kubectl get pods -o custom-columns=NAME:.metadata.name -l app.kubernetes.io/name=servicemanager --no-headers -n nonrtric)
    if [[ -n $SERVICEMANAGER_POD ]]; then
        kubectl exec $SERVICEMANAGER_POD -n nonrtric -- ./kongclearup
    else
        echo "Error - Servicemanager pod not found, didn't delete Kong routes and services for ServiceManager."
    fi
fi

kubectl delete namespace nonrtric
kubectl delete pv nonrtric-pv2
kubectl delete pv nonrtric-pv1
kubectl delete pv nonrtric-pv3
kubectl get pv | grep Released | awk '$1 {print$1}' | while read vol; do kubectl delete pv/${vol}; done
