#!/bin/bash
# ============LICENSE_START=======================================================
# Copyright (C) 2025 OpenInfra Foundation Europe. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
#

# This will add additional configuration to ves-collector deployment.

kubectl patch deployment onap-dcae-ves-collector -n onap --type=json \
  -p='[{"op": "replace", "path": "/spec/template/spec/initContainers/0/command", "value": ["sh", "-c", "
  cp -R /opt/app/VESCollector/etc/. /opt/app/VESCollector/etc_rw/;

  REL_18_FOLDER=/opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI;
  mkdir -p $REL_18_FOLDER;
  wget https://forge.3gpp.org/rep/sa5/MnS/-/archive/Rel-18/MnS-Rel-18.tar?path=OpenAPI -O $REL_18_FOLDER/MnS-Rel-18.tar;
  tar -tf $REL_18_FOLDER/MnS-Rel-18.tar | grep '\.yaml$' | xargs tar -xf $REL_18_FOLDER/MnS-Rel-18.tar --strip-components 2 -C $REL_18_FOLDER/;
  rm $REL_18_FOLDER/MnS-Rel-18.tar;

  for file in $REL_18_FOLDER/*.yaml; do
    filename=$(basename $file);
    schemaElement=\'{\\"publicURL\\": \\"https://forge.3gpp.org/rep/sa5/MnS/blob/Rel-18/OpenAPI/\'$filename\'\\",\\"localURL\\": \\"3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/\'$filename\'\\"}\';
    if [ -z \\"$schemaElementStr\\" ]; then
      schemaElementStr=\\"$schemaElement\\";
    else
      schemaElementStr=\\"$schemaElementStr,$schemaElement\\";
    fi;
  done;
  echo \\"schemaElementStr=\\"$schemaElementStr\\"\\";

  if [ -n \\"$schemaElementStr\\" ]; then
    sed -i \\"$ s|]|,${schemaElementStr}]|\\" /opt/app/VESCollector/etc_rw/externalRepo/schema-map.json;
  fi;
"]}]'


