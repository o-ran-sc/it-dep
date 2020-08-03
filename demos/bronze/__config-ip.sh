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
  if [ ! -z "$1" ]; then echo "$1"; fi
  read  -n 1 -p "Press any key to continue, or CTRL-C to abort" mainmenuinput
  echo
}


echo "This script sets up the IP address references for RIC and SMO clusters."
echo
echo "Reading RIC cluster IP address from envirronment variable \$RIC_IP."
if [ -z $(echo ${RIC_IP} | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}") ]; then
  read -p "Not found or not in right format.  Enter the external IP address of the RIC cluster: " RIC_IP
  echo
else
  echo "  Got ${RIC_IP}"
fi

echo "Reading SMO cluster IP address from envirronment variable \$SMO_IP."
if [ -z $(echo ${SMO_IP} | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}") ]; then
  read -p "Not found or not in right format.  Enter the external IP address of the SMO cluster: " SMO_IP
  echo
else
  echo "  Got ${SMO_IP}"
fi

echo
echo "Ready to configure demo scripts and Helm charts using RIC cluster at ${RIC_IP} and SMO cluster at ${SMO_IP}."
echo "If not correct, abort from this script, then export the correct values for the RIC_IP and SMO_IP environment variables."
acknowledge

export RIC_IP="$RIC_IP"
export SMO_IP="$SMO_IP"

# run fixes from git clone's root directory
PREVDIR="$PWD"
cd $(git rev-parse --show-toplevel)

if [ ! "$(ls -A ./ric-dep)" ]; then
  echo "ric-dep directory empty, running submodule command to fetch"
  git submodule update --init --recursive
  echo
fi

echo "Inject the RIC cluster IP address (${RIC_IP}) into NONRTRIC recipe..."
#./nonrtric/RECIPE_EXAMPLE/example_recipe.yaml:137:192.168.130.80
sed -i -e 's/"baseUrl":"http:\/\/192.168.130.80:32080\/a1mediator"/"baseUrl":"http:\/\/'"${RIC_IP}"':32080\/a1mediator"/g' ./nonrtric/RECIPE_EXAMPLE/example_recipe.yaml


echo "Inject the RIC and SMO cluster IP addresses (${RIC_IP} and ${SMO_IP}) into RICAUX recipe..."
#./ric-aux/RECIPE_EXAMPLE/example_recipe.yaml:40:ricip: "10.0.0.1"
#./ric-aux/RECIPE_EXAMPLE/example_recipe.yaml:40:auxip: "10.0.0.1"
sed -i -e 's/ricip: "10.0.0.1"/ricip: "'"${RIC_IP}"'"/g' ./ric-aux/RECIPE_EXAMPLE/example_recipe.yaml
sed -i -e 's/auxip: "10.0.0.1"/auxip: "'"${SMO_IP}"'"/g' ./ric-aux/RECIPE_EXAMPLE/example_recipe.yaml

echo "Inject the RIC and SMO cluster IP addresses (${RIC_IP} and ${SMO_IP}) into RIC recipe..."
#ric-dep/RECIPE_EXAMPLE/example_recipe.yaml:39:  ricip: "10.0.0.1"
#ric-dep/RECIPE_EXAMPLE/example_recipe.yaml:40:  auxip: "10.0.0.1"
sed -i -e 's/ricip: "10.0.0.1"/ricip: "'"${RIC_IP}"'"/g' ./ric-dep/RECIPE_EXAMPLE/example_recipe.yaml
sed -i -e 's/auxip: "10.0.0.1"/auxip: "'"${SMO_IP}"'"/g' ./ric-dep/RECIPE_EXAMPLE/example_recipe.yaml


echo
echo "Completed."
cd "$PREVDIR"
