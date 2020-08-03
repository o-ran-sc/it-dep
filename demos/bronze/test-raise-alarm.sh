#!/bin/bash

#set -x

acknowledge() {
  echo "$1"
  read  -n 1 -p "Press any key to continue" mainmenuinput
  echo
}


echo "This script demonstrates raising alarm within Near RT RIC"

DIRNAME="/tmp/tsflow-$(date +%Y%m%d%H%M)"
mkdir $DIRNAME
cd $DIRNAME

echo "===> Add network topology node for Near RT RIC"

ipaddr="$(kubectl get svc --all-namespaces | grep alarmadapter-http | awk '{print $4}')"
port="$(kubectl get svc --all-namespaces | grep alarmadapter-http | awk '{print $6}' | cut -f1 -d'/')"


OP="POST"
SpecificProblem="8006"
PerceivedSeverity="MAJOR"
AdditionalInfo="ethernet"
IdentifyingInfo="eth1"
curl -v -X $OP http://"$ipaddr":"$port"/ric/v1/alarms -d '{"SpecificProblem": "${SpecificProblem}", "PerceivedSeverity": "${PerceivedSeverity}", "AdditionalInfo": "${AdditionalInfo}", "IdentifyingInfo": "${IdentifyingInfo}"}'


OP="POST"
SpecificProblem="8005"
PerceivedSeverity="CRITICAL"
AdditionalInfo="network-down"
IdentifyingInfo="switch 1"
curl -v -X $OP http://"$ipaddr":"$port"/ric/v1/alarms -d '{"SpecificProblem": "${SpecificProblem}", "PerceivedSeverity": "${PerceivedSeverity}", "AdditionalInfo": "${AdditionalInfo}", "IdentifyingInfo": "${IdentifyingInfo}"}'




OP="DELETE"
SpecificProblem="8005"
PerceivedSeverity="CRITICAL"
AdditionalInfo="network-down"
IdentifyingInfo="switch 1"
curl -v -X $OP http://"$ipaddr":"$port"/ric/v1/alarms -d '{"SpecificProblem": "${SpecificProblem}", "PerceivedSeverity": "${PerceivedSeverity}", "AdditionalInfo": "${AdditionalInfo}", "IdentifyingInfo": "${IdentifyingInfo}"}'
