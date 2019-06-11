#!/bin/bash
################################################################################
#   Copyright (c) 2019 AT&T Intellectual Property.                             #
#   Copyright (c) 2019 Nokia.                                                  #
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

if (( $# != 1 )); then
  echo "Missing parameters: <xapp-name>"
  exit
fi

source ./scripts/ric_env.sh
if [ -z $__RICENV_SET__ ]; then
  echo "Edit your ric_env.sh for first!"
  exit
fi

# Update the local values
RESULT_DIR=./generated
rm -rf $RESULT_DIR && mkdir -p $RESULT_DIR && cp -rf ./helm $RESULT_DIR

FILELIST=$(find ./helm  \( -name "*.tpl" -o -name "*.yaml" \))
for f in $FILELIST; do
  envsubst '${__RUNRICENV_DOCKER_HOST__} ${__RUNRICENV_DOCKER_PORT__}' < $f > "$RESULT_DIR/$f";
done

# Rename the helm chart folder
mv $RESULT_DIR/helm/xapp-std $RESULT_DIR/helm/$1
find $RESULT_DIR/helm/$1 -type f | xargs sed -i -e "s/xapp-std/$1/g"

# Push to helm chart repo
helm package generated/helm/$1 | awk '{ print $NF }' | xargs mv -t $__RUNRICENV_HELMREPO_DIR__
helm repo index $__RUNRICENV_HELMREPO_DIR__
helm repo update
