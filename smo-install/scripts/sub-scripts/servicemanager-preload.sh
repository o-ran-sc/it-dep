#!/bin/bash

################################################################################
#   Copyright (C) 2024-2025 OpenInfra Foundation Europe. All rights reserved.  #
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

function get_published_apis_payload() {

    IFS=$'\n' read -d '' -r -a ipv4Ar <<< ${interfaceDescIpv4Addr}
    IFS=$'\n' read -d '' -r -a portAr <<< ${interfaceDescPort}
    IFS=$'\n' read -d '' -r -a securityMethodsAr <<< ${interfaceDescSecurityMethods}

    interfaceDescArLen=${#ipv4Ar[@]}
    >&2 echo "interfaceDescArLen: ${interfaceDescArLen}"

    # Iterate over the array using array indexing
    interfaceDescBlock=""
    for (( i=0; i<interfaceDescArLen; i++ )); do
        >&2 echo "ipv4Ar[$i]: ${ipv4Ar[$i]}"

        interfaceDescItem="
        {
            \"ipv4Addr\": \"${ipv4Ar[$i]}\",
            \"port\":  ${portAr[$i]},
            \"securityMethods\":  ${securityMethodsAr[$i]}
        }"
        interfaceDescBlock="${interfaceDescBlock}${interfaceDescItem}, "
        >&2 echo "interfaceDescItem: ${interfaceDescItem}"
    done

    # Trim the trailing space and comma
    interfaceDescBlock="${interfaceDescBlock%??}"

    >&2 echo "interfaceDescBlock: ${interfaceDescBlock}"


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

    for operation in ${operations_array[@]}; do
        >&2 echo "Operations Element: ${operation}"
    done

    ops_ar_length=${#operations_array[@]}

    >&2 echo "ops_ar_length operations_array ${ops_ar_length}"

    # Iterate over the array using array indexing
    resourceBlock=""
    for (( i=0; i<ops_ar_length; i++ )); do
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
                ${interfaceDescBlock}
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
    >&2 echo "payload ${payload}"

    echo $payload | jq .
}

function publish_service() {
    echo "Publish  service  for $service_name"

    aef_profiles=$(echo "$service" | jq -c '.value.AefProfiles')
    api_name=$(echo "$service" | jq -c '.value.ApiName')

    echo "$aef_profiles" | jq -c '.[]' | while read -r aef_profile; do

        interfaceDescriptions=$(echo "$aef_profile" | jq -c '.interfaceDescriptions')

        >&2 echo "interfaceDescriptions: ${interfaceDescriptions}";

        interfaceDescIpv4Addr=$(echo $interfaceDescriptions | jq -r .[]."ipv4Addr")
        interfaceDescPort=$(echo $interfaceDescriptions | jq .[]."port")
        interfaceDescSecurityMethods=$(echo $interfaceDescriptions | jq -c .[]."securityMethods")

        >&2 echo "interfaceDescIpv4Addr: ${interfaceDescIpv4Addr}";
        >&2 echo "interfaceDescPort: ${interfaceDescPort}";
        >&2 echo "interfaceDescSecurityMethods: ${interfaceDescSecurityMethods}";

        versions=$(echo "$aef_profile" | jq -c '.Versions[]')

        ApiVersion=$(echo "$versions" | jq -c '.ApiVersion')
        >&2 echo "ApiVersion: $ApiVersion"

        Resources=$(echo "$versions" | jq -c '.Resources[]')

        # Parse Resources
        declare -A resourcesAr

        commTypeCsv=""

        for row in $(echo "$Resources" | jq -c '.CommType'); do
            commType=$(echo "$row" | jq -r '.');
            >&2 echo "commType: $commType";
            commTypeCsv="${commTypeCsv}${commType} "
            >&2 echo "Building commTypeCsv ${commTypeCsv}"
        done

        commTypeCsv=$(echo "$commTypeCsv" | xargs)
        resourcesAr["CommType"]=${commTypeCsv}

        resourceNameCsv=""
        for row in $(echo "$Resources" | jq -c '.ResourceName'); do
            resourceName=$(echo "$row" | jq -r '.');
            >&2 echo "resourceName: $resourceName";
            resourceNameCsv="${resourceNameCsv}${resourceName} "
            >&2 echo "Building resourceNameCsv ${resourceNameCsv}"
        done
        resourceNameCsv=$(echo "$resourceNameCsv" | xargs)
        resourcesAr["ResourceName"]=$resourceNameCsv

        uriCsv=""
        for row in $(echo "$Resources" | jq -c '.Uri'); do
            uri=$(echo "$row" | jq -r '.');
            >&2 echo "uri: $uri";
            uriCsv="${uriCsv}${uri} "
            >&2 echo "Building uriCsv ${uriCsv}"
        done
        uriCsv=$(echo "$uriCsv" | xargs)
        resourcesAr["Uri"]=$uriCsv

        operationsCsv=""
        for row in $(echo "$Resources" | jq -c '.Operations'); do
            operations=$(echo "$row" | jq -r '.[]')
            >&2 echo "operations: $operations";
            operationsCsv="${operationsCsv}${operations},"
            >&2 echo "Building operationsCsv ${operationsCsv}"
        done
        resourcesAr["Operations"]=$operationsCsv

        payload=$(get_published_apis_payload)

        # Make the REST call
        url="http://${first_node_ip}:${servicemanager_node_port}/published-apis/v1/${apfId}/service-apis"
        >&2 echo "published-apis url: ${url}"
        response=$(curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$url")

        ret=$?
        if [ $ret -ne 0 ]; then
            echo "REST call to Service Manager/published-apis failed, error code $ret"
            return $ret
        fi

        resp_code=$(echo $response | jq -r '.status')
        if [ "$resp_code" != "null" ] && [ "$resp_code" != "201" ]; then
            echo "Failed to publish service $service_name with response code $resp_code"
        fi

        response=$(echo "${response}" | jq .)
        >&2 echo "Response for published service $service_name: $response"
    done
    return 0
}

function register_provider() {
    # Make the REST call
    url="http://${first_node_ip}:${servicemanager_node_port}/api-provider-management/v1/registrations"
    response=$(curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$url")

    ret=$?
    if [ $ret -ne 0 ]; then
        echo "REST call to Service Manager/api-provider-management failed, error code $ret"
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
    echo "Register provider for ${service_name}"
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
                SERVICE_STATUS=$(kubectl get service "$service" -n smo)
                if [ $? = 0 ]; then
                    >&2 echo "Service $service is found in smo"
                    result+="$service "
                else
                    >&2 echo "Service $service is not found in smo"
                fi
            fi
        fi
    done

    # Trim trailing whitespace
    result=$(echo "$result" | xargs)
    echo $result
}

function publish_services_from_config() {
    echo "Find running services"
    domainName="kong"
    running_services_list=$(find_running_services_from_config)

    # Iterate through the configured services
    echo "$json_config" | jq -c 'to_entries[]' | while read -r service; do
        service_name=$(echo "$service" | jq -r '.key')
        if echo "$running_services_list" | grep -q "$service_name"; then
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

# Ensure yq and jq are installed
if ! command -v yq &> /dev/null; then
    >&2 echo "yq is not installed. Installing yq..."
    ARCH=$(case $(uname -m) in x86_64) echo "amd64";; aarch64) echo "arm64";; *) uname -m;; esac)
    VERSION="v4.45.4"
    echo "yq is not installed. Installing yq..."
    sudo wget https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_${ARCH} -O /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
fi

if ! command -v jq &> /dev/null; then
    >&2 echo "jq is not installed. Installing jq..."
    ARCH=$(case $(uname -m) in x86_64) echo "amd64";; aarch64) echo "arm64";; *) uname -m;; esac)
    VERSION="1.8.1"
    echo "jq is not installed. Installing jq..."
    sudo wget https://github.com/jqlang/jq/releases/download/jq-${VERSION}/jq-linux-${ARCH} -O /usr/local/bin/jq
    sudo chmod +x /usr/local/bin/jq
fi

# Read and parse the YAML file
yaml_file="${1:-config.yaml}"
json_config=$(yq eval "$yaml_file" -o=json)

echo "Preloading Service Manager from ${yaml_file}"

# Get our Node IP and nodePort
servicemanager_node_port=$(kubectl get service servicemanager -n nonrtric -o jsonpath='{.spec.ports[0].nodePort}')
first_node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
if [ -z "$first_node_ip" ]; then
    echo "ExternalIP not found, using InternalIP"
    first_node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
else
    echo "Using ExternalIP ($first_node_ip) for Service Manager access"
    echo "Ensure the NodePort ($servicemanager_node_port) on node ($first_node_ip) is accessible from this machine"
    echo "If the port is not accessible, the publish action will hang on curl timeout"
fi

echo "Service Manager will be accessed at: http://${first_node_ip}:${servicemanager_node_port}"

publish_services_from_config

echo "Service Manager preload completed for ${yaml_file}"
