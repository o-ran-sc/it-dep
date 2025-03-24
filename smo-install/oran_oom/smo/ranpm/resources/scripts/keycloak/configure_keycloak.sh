#!/usr/bin/env bash
#  ============LICENSE_START===============================================
#  Copyright (C) 2025 OpenInfra Foundation Europe. All rights reserved.
#  ========================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  ============LICENSE_END=================================================
#

# Install required dependencies
sed -i -e 's/us.archive.ubuntu.com/archive.ubuntu.com/g' /etc/apt/sources.list
apt update
apt install -y curl jq gettext

# Create realm in keycloak
. scripts/keycloak_utils.sh

# Generic error printout function
# args: <numeric-response-code> <descriptive-string>
check_error() {
    if [ $1 -ne 0 ]; then
        echo "Failed: $2"
        echo "Exiting..."
        exit 1
    fi
}

create_realms nonrtric-realm
while [ $? -ne 0 ]; do
    create_realms nonrtric-realm
done

# Create client for admin calls
cid="console-setup"
create_clients nonrtric-realm $cid
check_error $?
generate_client_secrets nonrtric-realm $cid
check_error $?

cid="kafka-producer-pm-xml2json"
create_clients nonrtric-realm $cid
check_error $?
generate_client_secrets nonrtric-realm $cid
check_error $?

KAFKA_PM_XML_2_JSON_APP_CLIENT_SECRET=$(< .sec_nonrtric-realm_$cid)
kubectl create secret generic kafka-pm-xml-2-json --from-literal=client_secret=$KAFKA_PM_XML_2_JSON_APP_CLIENT_SECRET -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -n $NAMESPACE -f -

cid="kafka-producer-pm-json2kafka"
create_clients nonrtric-realm $cid
check_error $?
generate_client_secrets nonrtric-realm $cid
check_error $?

KAFKA_PM_JSON_2_KAFKA_APP_CLIENT_SECRET=$(< .sec_nonrtric-realm_$cid)
kubectl create secret generic kafka-pm-json-2-kafka --from-literal=client_secret=$KAFKA_PM_JSON_2_KAFKA_APP_CLIENT_SECRET -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -n $NAMESPACE -f -

cid="kafka-producer-pm-json2influx"
create_clients nonrtric-realm $cid
check_error $?
generate_client_secrets nonrtric-realm $cid
check_error $?

KAFKA_PM_JSON_2_INFLUX_APP_CLIENT_SECRET=$(< .sec_nonrtric-realm_$cid)
kubectl create secret generic kafka-pm-json-2-influx --from-literal=client_secret=$KAFKA_PM_JSON_2_INFLUX_APP_CLIENT_SECRET -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -n $NAMESPACE -f -

cid="pm-producer-json2kafka"
create_clients nonrtric-realm $cid
check_error $?
generate_client_secrets nonrtric-realm $cid
check_error $?

PM_PRODUCER_JSON_2_KAFKA_APP_CLIENT_SECRET=$(< .sec_nonrtric-realm_$cid)
kubectl create secret generic pm-producer-json-2-kafka --from-literal=client_secret=$PM_PRODUCER_JSON_2_KAFKA_APP_CLIENT_SECRET -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -n $NAMESPACE -f -

cid="dfc"
create_clients nonrtric-realm $cid
check_error $?
generate_client_secrets nonrtric-realm $cid
check_error $?

DFC_APP_CLIENT_SECRET=$(< .sec_nonrtric-realm_$cid)
kubectl create secret generic dfc --from-literal=client_secret=$DFC_APP_CLIENT_SECRET -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -n $NAMESPACE -f -

cid="nrt-pm-log"
create_clients nonrtric-realm $cid
check_error $?
generate_client_secrets nonrtric-realm $cid
check_error $?

PM_LOG_CLIENT_SECRET=$(< .sec_nonrtric-realm_$cid)
kubectl create secret generic pm-log --from-literal=client_secret=$PM_LOG_CLIENT_SECRET -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -n $NAMESPACE -f -

exit 0