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
apk add --no-cache curl jq envsubst

. scripts/ics_utils.sh
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

cid="console-setup"
TOKEN=$(get_client_token nonrtric-realm $cid)

JOB='{"info_type_id": "json-file-data-from-filestore-to-influx",
     "job_owner": "console",
     "status_notification_uri": "http://callback.nonrtric:80/post",
     "job_definition": {
        "db-url":"http://influxdb2:8086",
        "db-org":"est",
        "db-bucket":"pm-bucket",
        "db-token":"'$INFLUXDB2_TOKEN'",
        "filterType":"pmdata",
        "filter":{}
     }}'
echo $JOB > .job.json
create_ics_job kp-influx-json 0 $TOKEN

echo "done"




