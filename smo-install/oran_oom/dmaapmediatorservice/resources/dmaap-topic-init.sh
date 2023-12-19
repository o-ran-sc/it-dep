#!/bin/sh
################################################################################
#   Copyright (c) 2024 NYCU WINLab.                                            #
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

topics='{{ .Values.dmaapTopicInit.topics | toRawJson }}'

echo $topics | jq -c '.[]' | while read -r obj; do
    curl -X POST -H "Content-Type: application/json" -d "$obj" {{ .Values.dmaapTopicInit.dmaapMrAddr }}/topics/create
    response=$?
    if [ $response -ne 0 ]; then
        echo "Failed to create topic $obj"
        exit 1
    fi
done
