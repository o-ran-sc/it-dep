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


acknowledge "This script demonstrates the deployment of HelloWorld xApp."
DIRNAME="/tmp/tsflow-$(date +%Y%m%d%H%M)"
mkdir $DIRNAME
cd $DIRNAME

echo "===>  Generating xApp on-boarding file"
echo '{
  "config-file.json_url": "https://gerrit.o-ran-sc.org/r/gitweb?p=ric-app/hw.git;a=blob_plain;f=init/config-file.json;hb=HEAD"
}' > onboard.hw.url


echo "===>  On-boarding xApps"
curl --location --request POST "http://$(hostname):32080/onboard/api/v1/onboard/download" \
     --header 'Content-Type: application/json' --data-binary "@./onboard.hw.url"
acknowledge "A \"Created\" status indicates on-boarding successful."

echo "======> Listing on boarded xApps"
curl --location --request GET "http://$(hostname):32080/onboard/api/v1/charts"
acknowledge "Verify that the on-boarded xApp indeed is listed."

echo "===>  Deploy xApps"
curl --location --request POST "http://$(hostname):32080/appmgr/ric/v1/xapps" \
     --header 'Content-Type: application/json' --data-raw '{"xappName": "hwxapp"}'
acknowledge "A \"deployed\" status indicates that the xApp has been deployed."
# response: {"instances":null,"name":"trafficxapp","status":"deployed","version":"1.0"}

POD_HW=""
echo -n "Waiting for all newly deployed xApp pod(s) reaching running state."
while [ -z $POD_HW ]; do
  echo -n "."
  sleep 5
  POD_HW=$(kubectl get pods -n ricxapp | grep Running | grep "\-hwxapp\-" | cut -f1 -d ' ')
done
echo && echo "Now all newly deployed xApp(s) have reached running state"

echo && echo "======> Status of xApps"
kubectl get pods -n ricxapp

POD_A1=$(kubectl get pods -n ricplt | grep Running | grep "\-a1mediator\-" | cut -f1 -d ' ')
echo
echo "To view the logs of the A1 midiator, run the following "
echo "command in a separate terminal window:"
echo "  kubectl logs -f -n ricplt $POD_A1"

echo "To view the logs of the Hello World xapp, run the following "
echo "command in a separate terminal window:"
echo "  kubectl logs -f -n ricxapp $POD_HW"

acknowledge "When ready, "



echo "====>  Pushing policy type to A1"
POLICY_TYPE_ID="1"
cat << EOF > hw-policy-type-${POLICY_TYPE_ID}.json
{
  "name": "hwpolicy",
  "description": "Hellow World policy type",
  "policy_type_id": ${POLICY_TYPE_ID},
  "create_schema": {
    "\$schema": "http://json-schema.org/draft-07/schema#",
    "title": "HW Policy",
    "description": "HW policy type",
    "type": "object",
    "properties": {
      "threshold": {
        "type": "integer",
        "default": 0
      }
    },
    "additionalProperties": false
  }
}
EOF
echo "A policy type definition file hw-policy-type-${POLICY_TYPE_ID}.json has been created."
echo && acknowledge "The next command will create a new policy type via A1 Mediator using this definition file.  Watch the logs of A1 Mediator."
curl -v -X PUT "http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}" \
  -H "accept: application/json" -H "Content-Type: application/json" \
  -d @./hw-policy-type-${POLICY_TYPE_ID}.json
# expect to see a 201
acknowledge "A 201 response indicates that the new policy type has been created."

echo && echo "======> Listing policy types"
curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes
acknowledge "Verify that the policy type ${POLICY_TYPE_ID} is in the listing."


echo && acknowledge "The next command will create a new policy instance of the newly created policy type.  Watch the logs of A1 Mediator and HW xApp."
POLICY_ID="hwpolicy321"
echo && echo "===> Deploy policy ID of ${POLICY_ID} of policy type ${POLICY_TYPE_ID}"
curl -v -X PUT --header "Content-Type: application/json" \
  --data "{\"threshold\" : 9}" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies/${POLICY_ID}
acknowledge "A 202 response indicates that the new policy instance has been created.  In additoin, A1 Mediator and HW xApp log would indicate that the new policy instance has been distributed from A1 Mediator to the xApp."

# get policy instances
echo && echo "======> Listing policy instances of policy type ${POLICY_TYPE_ID}"
curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies
acknowledge "Verify that the new policy instance appears in the policy list"


echo && acknowledge "The above sequence has completed the Hello World xApp on-boarding, deployment, and policy distribution demonstration.  The remaining part of the script cleans up the HW xApp, policy type, and policy instance from the Near RT RIC"

echo && echo "===> Deleting policy instance ${POLICY_ID} of type ${POLICY_TYPE_ID}"
acknowledge "The next command will delete a policy instance.  Watch the logs of A1 Mediator andd HW xApp"
curl -X DELETE --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies/${POLICY_ID}
sleep 5

echo && echo "======> Listing policy instances"
curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies

echo && echo "===> Deleting policy type $POLICY_TYPE_ID"
acknowledge "The next command will delete a policy type.  Watch the logs of TS xApp"
curl -X DELETE -H "accept: application/json" -H "Content-Type: application/json" \
  "http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}"
sleep 5

echo && echo "======> Listing policy types"
curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes


echo && echo "===> Undeploy the xApps"
acknowledge "The next command will delete the HW xApp."
curl -H "Content-Type: application/json" -X DELETE \
  http://$(hostname):32080/appmgr/ric/v1/xapps/hwxapp
sleep 5

echo && echo "======> Listing xApps"
kubectl get pods -n ricxapp

echo
echo "That is all folks.  Thanks!"
