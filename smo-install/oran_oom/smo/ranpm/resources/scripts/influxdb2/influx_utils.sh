#!/usr/bin/env bash

#  ============LICENSE_START===============================================
#  Copyright (C) 2023 Nordix Foundation. All rights reserved.
#  Copyright (C) 2023-2025 OpenInfra Foundation Europe. All rights reserved.
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

# Script intended to be sourced by other script to add functions to the keycloak rest API

export INFLUXDB2PROTOCOL=${1:-$INFLUXDB2_PROTOCOL}
export INFLUXDB2HOSTNAME=${2:-$INFLUXDB2_HOST}
export INFLUXDB2_PORT=${3:-$INFLUXDB2_PORT}
export INFLUXDB2_ORGANIZATION=${4:-$INFLUXDB2_ORGANIZATION}
export INFLUXDB2_BUCKET=${5:-$INFLUXDB2_BUCKET}
export INFLUXDB2_USERNAME=${6:-$INFLUXDB2_USERNAME}
export INFLUXDB2_PASSWORD=${7:-$INFLUXDB2_PASSWORD}
export INFLUXDB2_DEFAULT_TOKEN=${8:-$INFLUXDB2_DEFAULT_TOKEN}

export INFLUXDB2_ORGANIZATION_ID=""

echo "Influx Protocol is: $INFLUXDB2PROTOCOL"
echo "Influx Host is: $INFLUXDB2HOSTNAME"
echo "Influx Port is: $INFLUXDB2_PORT"

INFLUXDB2HOST="$INFLUXDB2PROTOCOL://$INFLUXDB2HOSTNAME"

__wait_for_influxdb2_availability() {
    while true; do
        STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$INFLUXDB2HOST:$INFLUXDB2_PORT/api/v2/setup")
        if  [ "$STATUS_CODE" -eq 200 ]; then
            echo "Influxdb2 is ready."
            break
        fi
        echo "Influxdb2 is not ready..."
        sleep 5
    done
}

get_influxdb2_setup_allowed() {
    __influxdb2_setup_allowed=$(curl -s -X GET "$INFLUXDB2HOST:$INFLUXDB2_PORT/api/v2/setup" | jq -r '.allowed')
    if [ "$__influxdb2_setup_allowed" = "true" ]; then
        return 0
    fi
    return 1
}

setup_influxdb2() {

cat > .jsonfile1 <<- "EOF"
{
"bucket": "$INFLUXDB2_BUCKET",
"org": "$INFLUXDB2_ORGANIZATION",
"password": "$INFLUXDB2_PASSWORD",
"username": "$INFLUXDB2_USERNAME",
"retentionPeriodSeconds": 0,
"token":"$INFLUXDB2_DEFAULT_TOKEN"
}
EOF
    envsubst < .jsonfile1 > .jsonfile2
    RESPONSE=$(curl -s -X POST "$INFLUXDB2HOST:$INFLUXDB2_PORT/api/v2/setup" \
        -H "Content-Type: application/json" \
        -d @".jsonfile2")

    if [ $? -ne 0 ]; then
        echo "Command failed, setup influx"
        exit 1
    fi
    INFLUXDB2_ORGANIZATION_ID=$(echo "$RESPONSE" | jq -r '.org.id')
    echo "OK, Setup influx"
}

create_influxdb2_bucket() {
INFLUXDB2_BUCKET=$1
cat > .jsonfile1 <<- "EOF"
{
"name": "$INFLUXDB2_BUCKET",
"orgID": "$INFLUXDB2_ORGANIZATION_ID"
}
EOF
    envsubst < .jsonfile1 > .jsonfile2
    curl -s -X POST "$INFLUXDB2HOST:$INFLUXDB2_PORT/api/v2/buckets" \
        --header "Authorization: Token $INFLUXDB2_DEFAULT_TOKEN" \
        --header "Content-Type: application/json" \
        -d @".jsonfile2"

    if [ $? -ne 0 ]; then
        echo "Bucket $1 creation failed."
        exit 1
    fi
    echo "Bucket $1 created."
}

__wait_for_influxdb2_availability
