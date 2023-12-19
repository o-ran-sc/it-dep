#!/bin/sh

topics='{{ .Values.dmaapTopicInit.topics | toRawJson }}'

echo $topics | jq -c '.[]' | while read -r obj; do
    curl -X POST -H "Content-Type: application/json" -d "$obj" {{ .Values.dmaapTopicInit.dmaapMrAddr }}/topics/create
    response=$?
    if [ $response -ne 0 ]; then
        echo "Failed to create topic $obj"
        exit 1
    fi
done