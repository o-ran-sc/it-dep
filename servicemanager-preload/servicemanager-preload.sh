#!/bin/bash

################################################################################
#   Copyright (C) 2024 OpenInfra Foundation Europe. All rights reserved.       #
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

# Ensure yq and jq are installed
if ! command -v yq &> /dev/null; then
    echo "yq is required but not installed. Install it with: sudo apt-get install yq"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Install it with: sudo apt-get install jq"
    exit 1
fi

function get_registrations_payload() {
    payload="{
    \"apiProvDomInfo\": \"${domainName}\",
    \"apiProvFuncs\": [
        {
            \"apiProvFuncInfo\": \"${apf_info}\",
            \"apiProvFuncRole\": \"APF\",
            \"regInfo\": {
                \"apiProvPubKey\": \"APF-PublicKey\"
            }
        },
        {
            \"apiProvFuncInfo\": \"${aef_info}\",
            \"apiProvFuncRole\": \"AEF\",
            \"regInfo\": {
                \"apiProvPubKey\": \"AEF-PublicKey\"
            }
        }
    ],
    \"regSec\": \"${service_name}\"
}"
    echo $payload
}

function register_provider() {
    # Make the REST call
    url="http://${first_node_ip}:${servicemanager_node_port}/api-provider-management/v1/registrations"
    response=$(curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$url")

    check_resp=$(jq --argjson resp "$response" -n '$resp.apiProvDomId')
    if [ $check_resp != "null" ]; then
        status=201
    else
        status=$(jq --argjson resp "$response" -n '$resp.status')
    fi
    echo $status
}

function find_installed_services() {
    helm_values=$(helm get values r3-dev-nonrtric -n nonrtric -o json)
    install_keys=$(echo "$helm_values" | jq '.nonrtric | to_entries[] | select(.key | startswith("install")) | [.key, .value] | @sh')

    # Use a loop to process each line and append the result to the variable
    result=""
    while IFS= read -r kv; do
        output=$(echo "$kv" | tr -d \'\" | awk '{if ($2 == "true") print $1}')

        if [ -n "$output" ]; then
            stripped_string=$(echo "$output" | sed 's/^install//')
            lowercase_string=$(echo "$stripped_string" | tr '[:upper:]' '[:lower:]')
            result+="$lowercase_string "
        fi
    done <<< "$install_keys"

    # Trim trailing whitespace
    result=$(echo "$result" | xargs)
    echo $result
}

function get_published_apis_payload() {
    payload="{
    \"AefProfiles\": [
        {
            \"AefId\": \"${aefId}\",
            \"interfaceDescriptions\": [
                {
                    \"ipv4Addr\": \"${service_name}\",
                    \"port\": ${port},
                    \"securityMethods\": [
                        \"\"
                    ]
                }
            ],
            \"DomainName\": \"${domainName}\",
            \"Protocol\": \"HTTP_1_1\",
            \"Versions\": [
                {
                    \"ApiVersion\": \"\",
                    \"Resources\": [
                        {
                            \"CommType\": \"REQUEST_RESPONSE\",
                            \"Operations\": [
                                \"GET\"
                            ],
                            \"ResourceName\": \"route\",
                            \"Uri\": \"/\"
                        }
                    ]
                }
            ]
        }
    ],
    \"ApiName\": \"${api_name}\",
    \"Description\": \"Description,namespace,repoName,chartName,releaseName\"
}"
    echo $payload
}

function publish_service() {
    echo "Adding service: $service_name"

    service_ports=$(echo "$service" | jq -c '.value.ports')
    echo "Ports: $service_ports"

    # Iterate over each port object
    echo "$service_ports" | jq -c '.[]' | while read -r port_info; do
        port=$(echo "$port_info" | jq -r '.port')
        port_name=$(echo "$port_info" | jq -r '.name')

        echo "Port: $port, Name: $port_name"
        api_name="${service_name}-${port_name}"

        payload=$(get_published_apis_payload)
        echo "Payload: $payload"

        # Make the REST call
        url="http://${first_node_ip}:${servicemanager_node_port}/published-apis/v1/${apfId}/service-apis"
        echo "published-apis url: ${url}"
        response=$(curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$url")
        echo "Response for published service $service_name: $response"
    done
}

function register_apf() {
    # Prepare the JSON payload for the REST calls
    domainName="Kong"

    apf_info="${service_name} as APF"
    aef_info="${service_name} as AEF"
    aefId="AEF_id_${service_name}_as_AEF"
    apfId="APF_id_${service_name}_as_APF"

    payload=$(get_registrations_payload)
    echo $payload
    resp=$(register_provider)

    if [ $resp != 201 ]; then
        echo "Failed to register provider with code ${resp}"
        exit 1
    fi
}

function publish_services() {
    installed_services_list=$(find_installed_services)

    # Iterate through the configured services
    echo "$json_config" | jq -c 'to_entries[]' | while read -r service; do
        service_name=$(echo "$service" | jq -r '.key')
        switch_name=$(echo "$service" | jq -r '.value.switchname')
        if [ "$switch_name" = "null" ]; then
            switch_name=$service_name
        fi
        if echo "$installed_services_list" | grep -q "$switch_name"; then
            echo "found $service_name"
            register_apf
            publish_service
        fi
    done
}

# Read and parse the YAML file
yaml_config="${1:-config.yaml}"
json_config=$(yq read "$yaml_config" --tojson)

# Get our Node IP and nodePort
first_node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
servicemanager_node_port=$(kubectl get service servicemanager -n nonrtric -o jsonpath='{.spec.ports[0].nodePort}')

publish_services
