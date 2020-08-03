#!/bin/bash
################################################################################
#   Copyright (c) 2020 AT&T Intellectual Property.                             #
#                                                                              #
#   Licensed under the Apache License, Version 2.0 (the "License");            #
#   you may not use this file except in compliance with the License.           #
#   You may obtain a copy of the License at                                    #
#                                                                              #
#       http://www.apache.org/licenses/LICENSE-2.0                             #
#                                                                              #
#   Unless required by applicable law or agreed to in writing, software        #
#   distributed under the License is distributed on an "AS IS" BASIS,          #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
#   See the License for the specific language governing permissions and        #
#   limitations under the License.                                             #
################################################################################

#set -x

acknowledge() {
  echo "$1"
  read  -n 1 -p "Press any key to continue, or CTRL-C to abort" mainmenuinput
  echo
}

curl -k -X POST -H 'Content-Type: application/json' -d '{ "serverTimeMs": 0, "count": 1 }' \
  https://$(hostname):30226/events/A1-POLICY-AGENT-READ

curl -X "POST" "http://$(hostname):30093/actuator/loggers/org.oransc.policyagent.clients.AsyncRestClient" -H "Content-Type: application/json; charset=utf-8"   -d $'{ "configuredLevel": "TRACE" }'
sleep 2


RIC_NAME="ric1"
POLICY_TYPE_ID="20008"

echo && acknowledge "Listing the RICs that the NonRTRIC manages:"
curl -s http://$(hostname):30093/rics | jq .


echo && acknowledge "Now we have finished all prep work, switch the demo sequence to the RIC side."

echo "Back to SMO"
echo -n "Waiting for policy type ${POLICY_TYPE_ID} to show up in policy type list of ${RIC_NAME}"
PP=""
while [ -z "$PP" ]; do
  PP=$(curl -s http://$(hostname):30093/rics | jq '.[] | select(.ricName == "ric1") | .policyTypes | .[] ' | grep "${POLICY_TYPE_ID}")
  echo -n '.'
  sleep 1
done
echo
curl -s http://$(hostname):30093/rics | jq .

echo && acknowledge "The policy type is visiable, time to create policy instance.  After hitting any key to continue, look into the logs of the Traffic Steering xApp, it will receive the new policy and execute based on the new thhreshold value in the new policy instance."
# add a policy instance
POLICY_ID="tspolicy001"
curl -v -X PUT --header "Content-Type: application/json" -d '{"threshold" : 5}' \
  "http://$(hostname):30093/policy?id=${POLICY_ID}&ric=ric1&service=dummyService&type=${POLICY_TYPE_ID}"

acknowledge "Check for policy instances of type $POLICY_TYPE_ID on $RIC_NAME"
curl -s -X GET --header "Content-Type: application/json"  \
  "http://$(hostname):30093/policy_ids?ric=ric1&type=$POLICY_TYPE_ID" | jq .


echo && acknowledge "Now the SMO A1 flow is completed, we will start the cleaning"

echo && acknowledge "Delete the policy instance.  Pay attention to the Traffic Steering xApp's log to see its processing of the policy deletion."
curl -v -X DELETE --header "Content-Type: application/json"  "http://$(hostname):30093/policy?id=$POLICY_ID"


echo "The SMO part of the A1 flow is complete.  Go back to the RIC part of the demo sequence to complete.  Thank you."

