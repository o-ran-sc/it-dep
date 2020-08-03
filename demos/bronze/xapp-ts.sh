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
  read  -n 1 -p "Press any key to continue" mainmenuinput
  echo
}


echo "This script demonstrates the phase one of the Bronze release Traffic Steering use case."
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


echo "===>  On-boarding xApps"
curl --location --request POST "http://$(hostname):32080/onboard/api/v1/onboard/download" \
     --header 'Content-Type: application/json' --data-binary "@./onboard.ts.url"
curl --location --request POST "http://$(hostname):32080/onboard/api/v1/onboard/download" \
     --header 'Content-Type: application/json' --data-binary "@./onboard.qp.url"
curl --location --request POST "http://$(hostname):32080/onboard/api/v1/onboard/download" \
     --header 'Content-Type: application/json' --data-binary "@./onboard.qpd.url"

echo "======> Listing on boarded xApps"
curl --location --request GET "http://$(hostname):32080/onboard/api/v1/charts"


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

echo "======> Status of xApps"
kubectl get pods -n ricxapp

POD_QP=""
POD_QPD=""
POD_TS=""
while [ -z $POD_QP ] || [ -z $POD_QPD ] || [ -z $POD_TS ]; do
  echo "Not all new xApp pods are in running state."
  sleep 5
  POD_QP=$(kubectl get pods -n ricxapp | grep Running | grep "\-qp\-" | cut -f1 -d ' ')
  POD_QPD=$(kubectl get pods -n ricxapp | grep Running | grep "\-qpdriver\-" | cut -f1 -d ' ')
  POD_TS=$(kubectl get pods -n ricxapp | grep Running | grep "\-trafficxapp\-" | cut -f1 -d ' ')
done


POD_A1=$(kubectl get pods -n ricplt | grep Running | grep "\-a1mediator\-" | cut -f1 -d ' ')
echo "To view the logs of the A1 midiator, run the following "
echo "command in a separate terminal window:"
echo "  kubectl logs -f -n ricplt $POD_A1"

echo "To view the logs of the traffic steering xapp, run the following "
echo "command in a separate terminal window:"
echo "  kubectl logs -f -n ricplt $POD_TS"

acknowledge ""


# populate DB
echo "===> Inject DBaas with testing data for Traffic Steering test"
if [ ! -e ts ]; then
  git clone http://gerrit.o-ran-sc.org/r/ric-xapp/ts
fi
pushd "$(pwd)"
cd ts/test/populatedb
./populate_db.sh
popd


echo "====>  Pushing policy type to A1"
POLICY_TYPE_ID="20008"
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

acknowledge "The next command will create a new policy type.  Watch the logs of A1 Mediator"

curl -v -X PUT "http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}" \
  -H "accept: application/json" -H "Content-Type: application/json" \
  -d @./ts-policy-type-${POLICY_TYPE_ID}.json
# expect to see a 201

echo "======> Listing policy types"
curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes

acknowledge "The next command will create a new policy instance.  Watch the logs of A1 Mediator and TS xApp"

POLICY_ID="tsapolicy145"
echo "===> Deploy policy ID of ${POLICY_ID}" of policy type ${POLICY_TYPE_ID}"
curl -X PUT --header "Content-Type: application/json" \
  --data "{\"threshold\" : 5}" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies/${POLICY_ID}

# get policy instances
echo "======> Listing policy instances"
curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies

echo "Watch how TS processes the data retrieved from RNIB in TS logs"
acknowledge "After done we will start the removal process"


echo "===> Deleting policy instance"
acknowledge "The next command will delete a policy instance.  Watch the logs of A1 Mediator andd TS xApp"
curl -X DELETE --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies/${POLICY_ID}

echo "======> Listing policy instances"
curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}/policies

echo "===> Deleting policy type $POLICY_TYPE_ID"
acknowledge "The next command will delete a policy type.  Watch the logs of TS xApp"
curl -X DELETE -H "accept: application/json" -H "Content-Type: application/json" \
  "http://$(hostname):32080/a1mediator/a1-p/policytypes/${POLICY_TYPE_ID}"

echo "======> Listing policy types"
curl -X GET --header "Content-Type: application/json" --header "accept: application/json" \
  http://$(hostname):32080/a1mediator/a1-p/policytypes


echo "===> Unddeploy the xApps"
acknowledge "The next command will delete the TS, QP, and DPQ xApps."
curl -H "Content-Type: application/json" -X DELETE \
  http://$(hostname):32080/appmgr/ric/v1/xapps/trafficxapp
curl -H "Content-Type: application/json" -X DELETE \
  http://$(hostname):32080/appmgr/ric/v1/xapps/qp
curl -H "Content-Type: application/json" -X DELETE \
  http://$(hostname):32080/appmgr/ric/v1/xapps/qpdriver

echo "======> Listing xApps"
kubectl get pods -n ricxapp

