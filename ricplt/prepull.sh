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

# usage:   echo "{{YOUR_DOCKER_PASSWORD}}" | sh ./prepull.sh

DOCKER_REGISTRY="${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}"
IMAGE_LIST="xapp-manager:latest rtmgr:0.0.2 redis-standalone:latest e2mgr:1.0.0 e2:1.0.0"

docker login -u ${__RUNRICENV_DOCKER_USER__} --password-stdin ${DOCKER_REGISTRY}
for IMAGE in ${IMAGE_LIST}; do
  docker pull ${DOCKER_REGISTRY}/${IMAGE}
done

docker logout ${DOCKER_REGISTRY}
