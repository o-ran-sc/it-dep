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

export ICSPROTOCOL=${1:-$ICS_PROTOCOL}
export ICSHOSTNAME=${2:-$ICS_HOST}
export ICSPORT=${3:-$ICS_PORT}

echo "Ics Protocol is: $ICSPROTOCOL"
echo "Ics Host is: $ICSHOSTNAME"
echo "Ics Port is: $ICSPORT"

ICSHOST="$ICSPROTOCOL://$ICSHOSTNAME"

__wait_for_ics_availability() {
    while true; do
        STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$ICSHOST:$ICSPORT/status")
        if  [ "$STATUS_CODE" -eq 200 ]; then
            echo "Ics is ready."
            break
        fi
        echo "Ics is not ready..."
        sleep 5
    done
}

# args: <job-id> <job-index-suffix> [<access-token>]
# job file shall exist in file "".job.json"
create_ics_job() {
    JOB=$(<.job.json)
    echo $JOB
    retcode=1
    echo "Creating job-$1"'-'"$2"
    while [ $retcode -ne 0 ]; do
        if [ -z "$3" ]; then
            __bearer=""
        else
            __bearer="Authorization: Bearer $TOKEN"
        fi
        STAT=$(curl -s -X PUT -w '%{http_code}' -H accept:application/json -H Content-Type:application/json $ICSHOST:$ICSPORT/data-consumer/v1/info-jobs/job-$1"-"$2 --data-binary @.job.json -H "$__bearer" )
        retcode=$?
        echo "curl return code: $retcode"
        if [ $retcode -eq 0 ]; then
            status=${STAT:${#STAT}-3}
            echo "http status code: "$status
            if [ "$status" == "200" ]; then
                echo "Job created ok"
            elif [ "$status" == "201" ]; then
                echo "Job created ok"
            else
                retcode=1
            fi
        fi
        sleep 1
    done
}

# args: <job-id> <job-index-suffix> [<access-token>]
# job file shall exist in file "".job.json"
update_ics_job() {
    JOB=$(<.job.json)
    echo $JOB
    retcode=1
    echo "Updating job $1"
    while [ $retcode -ne 0 ]; do
        if [ -z "$2" ]; then
            __bearer=""
        else
            __bearer="Authorization: Bearer $TOKEN"
        fi
        STAT=$(curl -s -X PUT -w '%{http_code}' -H accept:application/json -H Content-Type:application/json $ICSHOST:$ICSPORT/data-consumer/v1/info-jobs/$1 --data-binary @.job.json -H "$__bearer" )
        retcode=$?
        echo "curl return code: $retcode"
        if [ $retcode -eq 0 ]; then
            status=${STAT:${#STAT}-3}
            echo "http status code: "$status
            if [ "$status" == "200" ]; then
                echo "Job created ok"
            elif [ "$status" == "201" ]; then
                echo "Job created ok"
            else
                retcode=1
            fi
        fi
        sleep 1
    done
}

__wait_for_ics_availability
