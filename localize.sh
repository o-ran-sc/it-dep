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

source ./runric_env.sh
if [ -z $__RICENV_SET__ ]; then
  echo "Edit your ric_env.sh for local infrastyructure values first"
  exit
fi

echo "Copy files to generated fir"
DIRS='kubernetes ricplt xapps platform'
rm -rf ./generated
mkdir -p generated
for d in $DIRS; do
  cp -rf $d ./generated/
done

echo "env substitude vars in .yaml and .sh files"
FILELIST=$(find .  \( -name "*.sh" -o -name "*.yaml" \))
for f in $FILELIST; do
  echo "$f to ./generated/$f":
  envsubst '${__RUNRICENV_GERRIT_HOST__}
${__RUNRICENV_GERRIT_IP__}
${__RUNRICENV_DOCKER_HOST__}
${__RUNRICENV_DOCKER_IP__}
${__RUNRICENV_DOCKER_PORT__}
${__RUNRICENV_DOCKER_USER__}
${__RUNRICENV_DOCKER_PASS__}
${__RUNRICENV_HELMREPO_HOST__}
${__RUNRICENV_HELMREPO_PORT__}
${__RUNRICENV_HELMREPO_IP__}
${__RUNRICENV_HELMREPO_USER__}
${__RUNRICENV_HELMREPO_PASS__} '< $f > "./generated/$f";
done


