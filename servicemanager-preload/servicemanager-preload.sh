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
if ! command -v yq > /dev/null 2>&1; then
    echo "yq is not installed. Installing yq..."
    sudo snap install yq --channel=v4/stable
fi

if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    sudo snap install jq
fi

function get_published_apis_payload() {
    payload="{
    \"AefProfiles\": [
        {
            \"AefId\": \"${aefId}\",
            \"interfaceDescriptions\": [
                {
                    \"ipv4Addr\": \"${service_name}.nonrtric.svc.cluster.local\",
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
                            \"ResourceName\": \"${api_name}\",
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
    \"regSec\": \"${service_name}-regsec\"
}"
    echo $payload
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

function find_running_services_from_config() {
    result=""

    # Extract service names from YAML using yq and strip leading/trailing whitespace
    SERVICE_NAMES=$(yq eval '. | keys[]' "$yaml_file")

    # Check each service using kubectl
    for service in $SERVICE_NAMES; do
        >&2 echo "Checking service: $service in nonrtric"
        # Use kubectl get to check if the service exists and capture the output
        SERVICE_STATUS=$(kubectl get service "$service" -n nonrtric)

        if [ $? = 0 ]; then
            >&2 echo "Service $service is found in nonrtric"
            result+="$service "
        else
            >&2 echo "Service $service is not running in nonrtric"
            SERVICE_STATUS=$(kubectl get service "$service" -n onap)
            if [ $? = 0 ]; then
                >&2 echo "Service $service is found in onap"
                result+="$service "
            else
                >&2 echo "Service $service is not found in onap"
            fi
        fi
    done

    # Trim trailing whitespace
    result=$(echo "$result" | xargs)
    echo $result
}

function publish_services_from_config() {
    running_services_list=$(find_running_services_from_config)

    # Iterate through the configured services
    echo "$json_config" | jq -c 'to_entries[]' | while read -r service; do
        service_name=$(echo "$service" | jq -r '.key')
        if echo "$running_services_list" | grep -q "$service_name"; then
            >&2 echo "Publish service: $service_name"
            register_apf
            publish_service
        fi
    done
}

# Read and parse the YAML file
yaml_file="${1:-config.yaml}"
json_config=$(yq eval "$yaml_file" -o=json)

# Get our Node IP and nodePort
first_node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
servicemanager_node_port=$(kubectl get service servicemanager -n nonrtric -o jsonpath='{.spec.ports[0].nodePort}')

publish_services_from_config
