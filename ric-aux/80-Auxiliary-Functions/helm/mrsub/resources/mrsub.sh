#!/bin/bash

MR_HOSTPORT="$_MR_HOSTPORT"
MR_TOPIC="$_MR_TOPIC"
LOGSTASH_URL="$_LOGSTASH_URL"

if ! jq --version > /dev/null 2&>1 ; then
  apt-get update
  apt-get install -y jq curl
fi

echo "IN SCRIPT"
echo "$MR_HOSTPORT   $MR_TOPIC  $LOGSTASH_URL"

while true; do
  # if dmaap returns single JSON structure
  DATA=$(curl -s -H "Accept: application/json" -X GET http://${MR_HOSTPORT}/events/${MR_TOPIC}/elk-plotter/elk-plotter?timeout=60000)
  DATA=$(echo $DATA| sed -e 's/\\"/"/g' -e 's/"{/{/g' -e 's/}"/}/g')
  echo "Getting data: $DATA"

  #VESEVENT=$(echo $DATA |jq -r '((.event.commonEventHeader.lastEpochMicrosec)|tostring) + "," + ((.event.measurementsForVfScalingFields.vNicUsageArray[0].receivedTotalPacketsDelta) | tostring)')
  #curl -i -XPUT 'http://127.0.0.1:8080/onenumber/onenumebr' -d "${VESEVENT}"

  # dmaap returns json array
  # echo "Reading source: $.event.commonEventHeader.reportingEntityName"
  source=$(echo $DATA |jq -r '.[] | ((.event.commonEventHeader.reportingEntityName) | tostring)')
  echo "Source name: $source"
  if [ "$source" == "GS_LITE MC" ]
  then
    DATA=$(echo $DATA |jq -r --arg source "$source"  '.[] | $source+","+((.event.measurementsForVfScalingFields.additionalFields[1].value) | tostring)+ ","+ ((.event.measurementsForVfScalingFields.additionalFields[2].value) | tostring)')
  #EVENTS=$(echo $DATA |jq -r '.event.measurementFields.additionalFields.SgNBRequestRate')
  #for EVENT in $EVENTS; do
  elif [ "$source" == "AC xAPP" ] 
  then  
    DATA=$(echo $DATA |jq -r --arg source "$source"  '.[] | $source+","+((.event.measurementsForVfScalingFields.additionalFields[0].value) | tostring)')
  else
    DATA="No supportive reporting entity provided"
  fi
  echo "Injecting VES event: $DATA"
  curl -i -XPUT "${LOGSTASH_URL}" -d "${DATA}"
  #done
done

