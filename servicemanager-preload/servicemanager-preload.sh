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
    declare -a commType_array
    read -r -a commType_array <<< "${resourcesAr["CommType"]}"


    declare -a resourceName_array
    read -r -a resourceName_array <<< "${resourcesAr["ResourceName"]}"

    declare -a uri_array
    read -r -a uri_array <<< "${resourcesAr["Uri"]}"

    declare -a ops_array

    ops_array=$(echo ${resourcesAr["Operations"]} | tr ' ' '*')

    declare -a operations_array

    IFS=',' read -r -a operations_array <<< "${ops_array}"

    # for operation in ${operations_array[@]}; do
    #     >&2 echo "Operations Element: ${operation}"
    # done

    array_length=${#commType_array[@]}

    # Iterate over the array using array indexing
    resourceBlock=""
    for (( i=0; i<array_length; i++ )); do
        IFS='*' read -r -a ops_per_resource <<< "${operations_array[$i]}"

        resourceStart="
        {
            \"CommType\": \"${commType_array[$i]}\",
            \"Operations\": [
                "

        # Print the array elements
        resourceMid=""
        for element in "${ops_per_resource[@]}"; do
            resourceMid="${resourceMid}\"${element}\", "
        done

        resourceMid=$(sed 's/..$//' <<< "$resourceMid")
        resourceMid="${resourceMid}
            ],"


        resourceEnd="
            \"ResourceName\": \"${resourceName_array[$i]}\",
            \"Uri\": \"${uri_array[$i]}\"
        }"


        resourceItem="${resourceStart}${resourceMid}${resourceEnd}"

        resourceBlock="${resourceBlock}${resourceItem}, "
    done

    resourceBlock=${resourceBlock::-2}


    payload="{
    \"AefProfiles\": [
        {
            \"AefId\": \"${aefId}\",
            \"interfaceDescriptions\": [
                {
                    \"ipv4Addr\": \"${service_name}.nonrtric.svc.cluster.local\",
                    \"port\": ${port},
                    \"securityMethods\": [
                        \"${securityMethod}\"
                    ]
                }
            ],
            \"DomainName\": \"${domainName}\",
            \"Protocol\": \"HTTP_1_1\",
            \"Versions\": [
                {
                    \"ApiVersion\": ${ApiVersion},
                    \"Resources\": [
                    ${resourceBlock}
                    ]
                }
            ]
        }
    ],
    \"ApiName\": ${api_name},
    \"Description\": \"Description,namespace,repoName,chartName,releaseName\"
}"
    echo $payload | jq .
}

function publish_service() {
    echo "Adding service: $service_name"

    aef_profiles=$(echo "$service" | jq -c '.value.AefProfiles')
    api_name=$(echo "$service" | jq -c '.value.ApiName')


    # Iterate over each port object
    echo "$aef_profiles" | jq -c '.[]' | while read -r aef_profile; do

        interfaceDescription=$(echo "$aef_profile" | jq -c '.interfaceDescriptions[]')

        ipv4Addr=$(echo "$interfaceDescription" | jq -c '.ipv4Addr')

        port=$(echo "$interfaceDescription" | jq -c '.port')

        securityMethods=$(echo "$interfaceDescription" | jq -c '.securityMethods')

        securityMethod=$(echo "$securityMethods" | jq -r '.[]')

        versions=$(echo "$aef_profile" | jq -c '.Versions[]')

        ApiVersion=$(echo "$versions" | jq -c '.ApiVersion')

        Resources=$(echo "$versions" | jq -c '.Resources[]')

        # Parse Resources
        declare -A resourcesAr

        commTypeCsv=""
        for row in $(echo "$Resources" | jq -c '.CommType'); do
           type=$(echo "$row" | jq -r '.');
        #    >&2 echo "type: $type";
           commTypeCsv="${commTypeCsv}${type} "
        #    >&2 echo "Building commTypeCsv ${commTypeCsv}"
        done
        commTypeCsv=$(echo "$commTypeCsv" | xargs)
        resourcesAr["CommType"]=$commTypeCsv

        resourceNameCsv=""
        for row in $(echo "$Resources" | jq -c '.ResourceName'); do
           resourceName=$(echo "$row" | jq -r '.');
        #    >&2 echo "resourceName: $resourceName";
           resourceNameCsv="${resourceNameCsv}${resourceName} "
        #    >&2 echo "Building resourceNameCsv ${resourceNameCsv}"
        done
        resourceNameCsv=$(echo "$resourceNameCsv" | xargs)
        resourcesAr["ResourceName"]=$resourceNameCsv

        uriCsv=""
        for row in $(echo "$Resources" | jq -c '.Uri'); do
           uri=$(echo "$row" | jq -r '.');
        #    >&2 echo "uri: $uri";
           uriCsv="${uriCsv}${uri} "
        #    >&2 echo "Building uriCsv ${uriCsv}"
        done
        uriCsv=$(echo "$uriCsv" | xargs)
        resourcesAr["Uri"]=$uriCsv

        operationsCsv=""
        for row in $(echo "$Resources" | jq -c '.Operations'); do
           operations=$(echo "$row" | jq -r '.[]')
        #    >&2 echo "operations: $operations";
           operationsCsv="${operationsCsv}${operations},"
        #    >&2 echo "Building operationsCsv ${operationsCsv}"
        done
        resourcesAr["Operations"]=$operationsCsv

        payload=$(get_published_apis_payload)

        # Make the REST call
        url="http://${first_node_ip}:${servicemanager_node_port}/published-apis/v1/${apfId}/service-apis"
        echo "published-apis url: ${url}"
        response=$(curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$url")

        ret=$?
        if [ $ret -ne 0 ]; then
            >&2 echo "REST call to Service Manager/published-apis failed, error code $ret"
            return $ret
        fi

        # response=$(echo "${response}" | jq .)
        echo "Response for published service $service_name: $response"
    done
    return 0
}

function register_provider() {
    # Make the REST call
    url="http://${first_node_ip}:${servicemanager_node_port}/api-provider-management/v1/registrations"
    response=$(curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$url")

    ret=$?
    if [ $ret -ne 0 ]; then
        >&2 echo "REST call to Service Manager/api-provider-management failed, error code $ret"
        status="$ret"
    else
        check_resp=$(jq --argjson resp "$response" -n '$resp.apiProvDomId')
        if [ $check_resp != "null" ]; then
            status=201
        else
            status=$(jq --argjson resp "$response" -n '$resp.status')
        fi
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
    apf_info="${service_name} as APF"
    aef_info="${service_name} as AEF"
    aefId="AEF_id_${service_name}_as_AEF"
    apfId="APF_id_${service_name}_as_APF"

    payload=$(get_registrations_payload)
    >&2 echo "Registration payload: $payload"
    resp=$(register_provider)

    if [ $resp != 201 ]; then
        >&2 echo "Failed to register provider with error code ${resp}"
        return $resp
    fi
    return 0
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
    domainName="kong"
    running_services_list=$(find_running_services_from_config)

    # Iterate through the configured services
    echo "$json_config" | jq -c 'to_entries[]' | while read -r service; do
        service_name=$(echo "$service" | jq -r '.key')
        if echo "$running_services_list" | grep -q "$service_name"; then
            >&2 echo "Publish service: $service_name"

            register_apf
            ret=$?
            if [ $ret -ne 0 ]; then
                break
            fi

            publish_service
            ret=$?
            if [ $ret -ne 0 ]; then
                break
            fi
        fi
    done
}

# Read and parse the YAML file
yaml_file="${1:-config.yaml}"
json_config=$(yq eval "$yaml_file" -o=json)

# Get our Node IP and nodePort
first_node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
servicemanager_node_port=$(kubectl get service servicemanager -n nonrtric -o jsonpath='{.spec.ports[0].nodePort}')

>&2 echo "Waiting for capifcore deployment"
kubectl wait --for=condition=Available -n nonrtric --timeout=90s deploy/capifcore

>&2 echo "Waiting for servicemanager deployment"
kubectl wait --for=condition=Available -n nonrtric --timeout=90s deploy/servicemanager

>&2 echo "Waiting for kong deployment"
kubectl wait --for=condition=Available -n nonrtric --timeout=90s deploy/oran-nonrtric-kong

publish_services_from_config
