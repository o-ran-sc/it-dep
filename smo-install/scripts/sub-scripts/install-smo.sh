#!/bin/bash
# ============LICENSE_START=======================================================
# Copyright (C) 2024 OpenInfra Foundation Europe. All rights reserved.
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

echo  '### Installing ORAN SMO part ###'
kubectl create namespace smo

OVERRIDEYAML=$1

check_for_dep() {
    try=0
    retries=60
    until (kubectl get deployment -n smo | grep -P "\b$1\b") >/dev/null 2>&1; do
        try=$(($try + 1))
        [ $try -gt $retries ] && exit 1
        echo "$1 not found. Retry $try/$retries"
        sleep 10
    done
    echo "$1 found. Waiting for pod intialisation"
    sleep 15
}

ORAN_STRIMZI_NAME="oran-strimzi"
ORAN_STRIMZI_ENTITY_OPERATOR="$ORAN_STRIMZI_NAME-entity-operator"

helm install $ORAN_STRIMZI_NAME local/strimzi -n smo -f $OVERRIDEYAML

echo "waiting for $ORAN_STRIMZI_ENTITY_OPERATOR to be deployed"

check_for_dep $ORAN_STRIMZI_ENTITY_OPERATOR

helm install --debug oran-smo local/smo --namespace smo -f $OVERRIDEYAML
