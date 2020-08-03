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


echo "This scripts demonstrates the Bronze release Traffic Steering use case, as well as the RIC part of the SMO A1 use case."
DIRNAME="/tmp/tsflow-$(date +%Y%m%d%H%M)"
mkdir $DIRNAME
cd $DIRNAME

echo "===>  Generating xApp on-boarding file"
echo '{
  "config-file.json_url": "https://gerrit.o-ran-sc.org/r/gitweb?p=ric-app/qp.git;a=blob_plain;f=xapp-descriptor/config.json;hb=HEAD" 
}' > onboard.qp.url
echo '{
  "config-file.json_url": "https://gerrit.o-ran-sc.org/r/gitweb?p=ric-app/qp-driver.git;a=blob_plain;f=xapp-descriptor/config.json;hb=HEAD"
}' > onboard.qpd.url
echo '{
  "config-file.json_url": "https://gerrit.o-ran-sc.org/r/gitweb?p=ric-app/ts.git;a=blob_plain;f=xapp-descriptor/config.json;hb=HEAD"
}' > onboard.ts.url


echo "===>  On-boarding three xApps: Traffic Steering, Quality Predictor, and Quality Predictor Driver."
curl --location --request POST "http://$(hostname):32080/onboard/api/v1/onboard/download" \
     --header 'Content-Type: application/json' --data-binary "@./onboard.ts.url"
curl --location --request POST "http://$(hostname):32080/onboard/api/v1/onboard/download" \
     --header 'Content-Type: application/json' --data-binary "@./onboard.qp.url"
curl --location --request POST "http://$(hostname):32080/onboard/api/v1/onboard/download" \
     --header 'Content-Type: application/json' --data-binary "@./onboard.qpd.url"
acknowledge "A \"Created\" status indicates on-boarding successful."

echo "======> Listing on boarded xApps"
curl --location --request GET "http://$(hostname):32080/onboard/api/v1/charts"
acknowledge "Verify that the on-boarded xApps indeed are listed."

echo "====>  Deploy xApps"
curl --location --request POST "http://$(hostname):32080/appmgr/ric/v1/xapps" \
     --header 'Content-Type: application/json' --data-raw '{"xappName": "qp"}'
# response: {"instances":null,"name":"qp","status":"deployed","version":"1.0"}
curl --location --request POST "http://$(hostname):32080/appmgr/ric/v1/xapps" \
     --header 'Content-Type: application/json' --data-raw '{"xappName": "qpdriver"}'
# response: {"instances":null,"name":"qpdriver","status":"deployed","version":"1.0"}
curl --location --request POST "http://$(hostname):32080/appmgr/ric/v1/xapps" \
     --header 'Content-Type: application/json' --data-raw '{"xappName": "trafficxapp"}'
# response: {"instances":null,"name":"trafficxapp","status":"deployed","version":"1.0"}
acknowledge "A \"deployed\" status indicates that the xApp has been deployed."


echo "======> Status of xApps"
kubectl get pods -n ricxapp


echo -n "Waiting for all newly deployed xApp pod(s) reaching running state."
POD_QP=""
POD_QPD=""
POD_TS=""
while [ -z $POD_QP ] || [ -z $POD_QPD ] || [ -z $POD_TS ]; do
  echo -n "."
  sleep 5
  POD_QP=$(kubectl get pods -n ricxapp | grep Running | grep "\-qp\-" | cut -f1 -d ' ')
  POD_QPD=$(kubectl get pods -n ricxapp | grep Running | grep "\-qpdriver\-" | cut -f1 -d ' ')
  POD_TS=$(kubectl get pods -n ricxapp | grep Running | grep "\-trafficxapp\-" | cut -f1 -d ' ')
done
echo && echo "Now all newly deployed xApp(s) have reached running state"


POD_A1=$(kubectl get pods -n ricplt | grep Running | grep "\-a1mediator\-" | cut -f1 -d ' ')
echo
echo "To view the logs of the A1 midiator, run the following "
echo "command in a separate terminal window:"
echo "  kubectl logs -f -n ricplt $POD_A1"

echo "To view the logs of the Traffic Steering xapp, run the following "
echo "command in a separate terminal window:"
echo "  kubectl logs -f -n ricxapp $POD_TS"

acknowledge "When ready, "


# populate DB
echo && echo "===> Inject DBaaS (RNIB) with testing data for Traffic Steering test"
if [ ! -e ts ]; then
  git clone http://gerrit.o-ran-sc.org/r/ric-app/ts
fi
pushd "$(pwd)"
cd ts/test/populatedb
./populate_db.sh
popd
acknowledge "RNIB populated.  The Traffic Steering xApp's log should inicate that it is reading RAN data.  When ready for the next step, "


POLICY_TYPE_ID="20008"
echo "====>  Creating policy type ${POLICY_TYPE_ID} via A1"
cat << EOF > ts-policy-type-${POLICY_TYPE_ID}.json
{
  "name": "tsapolicy",
  "description": "tsa parameters",
  "policy_type_id": ${POLICY_TYPE_ID},
  "create_schema": {
    "\$schema": "http://json-schema.org/draft-07/schema#",
    "title": "TS Policy",
    "description": "TS policy type",
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
echo "A policy type definition file ts-policy-type-${POLICY_TYPE_ID}.json has been created."
echo && acknowledge "The next command will create a new policy type via A1 Mediator using this definition file.  Watch the logs of A1 Mediator for confirmation."


curl -v -X PUT "http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}" \
  -H "accept: application/json" -H "Content-Type: application/json" \
  -d @./ts-policy-type-${POLICY_TYPE_ID}.json
# expect to see a 201
acknowledge "A 201 response indicates that the new policy type has been created."


echo "======> Listing policy types"
curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes
acknowledge "Verify that the policy type ${POLICY_TYPE_ID} is in the listing."

echo && acknowledge "The next steps will be carried out in the SMO cluster by the a1-smo.sh script.  After being suggested by the a1-smo.sh script to come back to tis script, " 

POLICY_ID="tsapolicy145"
if [ "${LOCAL_POLICY_INSTANCE}" = "Y" ]; then
  echo && acknowledge "The next command will create a new policy instance.  Watch the logs of A1 Mediator and TS xApp"

  echo "===> Deploy policy ID of ${POLICY_ID} of policy type ${POLICY_TYPE_ID}"
  curl -X PUT --header "Content-Type: application/json" \
    --data "{\"threshold\" : 5}" \
    http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies/${POLICY_ID}
  acknowledge "A 202 response indicates that the new policy instance has been created.  In additoin, A1 Mediator and HW xApp log would indicate that the new policy instance has been distributed from A1 Mediator to the xApp."


  # get policy instances
  echo "======> Listing policy instances"
  curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
    http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies
  acknowledge "Verify that the new policy instance appears in the policy list.  Also watch the A1 Mediator and TS xApp log for policyc distribution, and how TS xApp processes the RNIB data following the new policy instance (with updated treshold)."

fi


echo && acknowledge "The above sequence has completed the Hello World xApp on-boarding, deployment, and policy distribution demonstration.  The remaining part of the script cleans up the three xApps, and the policy type from the Near RT RIC"

if [ "${LOCAL_POLICY_INSTANCE}" = "Y" ]; then
  echo && echo "===> Deleting policy instance ${POLICY_ID} of type ${POLICY_TYPE_ID}"
  acknowledge "The next command will delete a policy instance.  Watch the logs of A1 Mediator andd TS xApp"
  curl -X DELETE --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies/${POLICY_ID}
  sleep 5

  echo && echo "======> Listing policy instances"
  curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
    http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies
fi

echo && echo "===> Deleting policy type $POLICY_TYPE_ID"
acknowledge "The next command will delete a policy type.  Watch the logs of A1 Mediator."
curl -X DELETE -H "accept: application/json" -H "Content-Type: application/json" \
  "http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}"
sleep 5

echo && echo "======> Listing policy types"
curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes

echo && echo "===> Undeploy the xApps"
acknowledge "The next command will delete the TS, QP, and DPQ xApps."
curl -H "Content-Type: application/json" -X DELETE \
  http://$(hostname):32080/appmgr/ric/v1/xapps/trafficxapp
curl -H "Content-Type: application/json" -X DELETE \
  http://$(hostname):32080/appmgr/ric/v1/xapps/qp
curl -H "Content-Type: application/json" -X DELETE \
  http://$(hostname):32080/appmgr/ric/v1/xapps/qpdriver
sleep 5

echo && echo "======> Listing xApps"
kubectl get pods -n ricxapp


echo
echo "That is all folks.  Thanks!"
