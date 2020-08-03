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
  read  -n 1 -p "Press any key to continue, or CTRL to abort." mainmenuinput
  echo
}


echo "This script demonstrates how to raise alarm in Nearr RT RIC using API call."

DIRNAME="/tmp/o1-$(date +%Y%m%d%H%M)"
mkdir $DIRNAME
cd $DIRNAME


aa_ipaddr="$(kubectl get svc --all-namespaces | grep alarmadapter-http | awk '{print $4}')"
aa_port="$(kubectl get svc --all-namespaces | grep alarmadapter-http | awk '{print $6}' | cut -f1 -d'/')"

echo && acknowledge "Next step: raising an alarm 8005 (network down CRITICAL) by calling AlarmAdapter API"
cmd="POST"
problem="8005"
severity="CRITICAL"
additionialinfo="network-down"
identityinfo="abcd-123"
# alarm-cli raise 8005 CRITICAL network-down abdc-123
APICALL="curl -v -X $cmd http://$aa_ipaddr:$aa_port/ric/v1/alarms -d '{\"SpecificProblem\": $problem, \"PerceivedSeverity\": \"$severity\", \"AdditionalInfo\": \"$additionialinfo\", \"IdentifyingInfo\": \"$identityinfo\"}'"
echo "running [$APICALL]"
eval $APICALL
sleep 5 
echo "A 200 response means that the API call was successful."

echo && acknowledge "Next step: raising an alarm 8006 (ethernet eth12 MAJOR) by calling AlarmAdapter API"
cmd="POST"
problem="8006"
severity="MAJOR"
additionialinfo="ethernet"
identityinfo="eth12"
# alarm-cli raise 8006 MAJOR ethernet eth12
APICALL="curl -v -X $cmd http://$aa_ipaddr:$aa_port/ric/v1/alarms -d '{\"SpecificProblem\": $problem, \"PerceivedSeverity\": \"$severity\", \"AdditionalInfo\": \"$additionialinfo\", \"IdentifyingInfo\": \"$identityinfo\"}'"
echo "running [$APICALL]"
eval $APICALL
sleep 5
echo "A 200 response means that the API call was successful."


echo && acknowledge "Take the next step in SMO terminal to see the alarm list that SMO receives from Near RT RIC.  After seeing the alarm list, come back and proceed with the next step in RIC." 

#o1-cli.go --host 10.103.67.128 --action get --namespace urn:o-ran:ric:alarm:1.0
echo && acknowledge "The next step: delete the alarm 8006 by calling AlarmAdapter API"
cmd="DELETE"
problem="8006"
severity="MAJOR"
additionialinfo="ethernet"
identityinfo="eth12"
# alarm-cli delete 8006 MAJOR ethernet eth12
APICALL="curl -v -X $cmd http://$aa_ipaddr:$aa_port/ric/v1/alarms -d '{\"SpecificProblem\": $problem, \"PerceivedSeverity\": \"$severity\", \"AdditionalInfo\": \"$additionialinfo\", \"IdentifyingInfo\": \"$identityinfo\"}'"
echo "running [$APICALL]"
eval $APICALL
sleep 10
echo "A 200 response means that the API call was successful."

echo && acknowledge "Take the next step in SMO terminal to see the alarm list that SMO receives from Near RT RIC.  After seeing the alarm list, come back and proceed with the next step in RIC."


echo && acknowledge "Clearing all remaining alarms."
cmd="DELETE"
problem="8005"
severity="CRITICAL"
additionialinfo="network-down"
identityinfo="abcd-123"
# alarm-cli delete 8005 CRITICAL network-down abdc-123
APICALL="curl -v -X $cmd http://$aa_ipaddr:$aa_port/ric/v1/alarms -d '{\"SpecificProblem\": $problem, \"PerceivedSeverity\": \"$severity\", \"AdditionalInfo\": \"$additionialinfo\", \"IdentifyingInfo\": \"$identityinfo\"}'"
echo "running [$APICALL]"
eval $APICALL
sleep 5

echo "That is all.  Thanks."
