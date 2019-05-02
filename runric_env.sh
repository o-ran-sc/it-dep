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


# customize the following repo info to local infrastructure
export __RICENV_SET__='YES'
export __RUNRICENV_GERRIT_HOST__='gerrit.ranco-dev-tools.eastus.cloudapp.azure.com'
export __RUNRICENV_GERRIT_IP__='137.135.91.204'

export __RUNRICENV_DOCKER_HOST__='snapshot.docker.ranco-dev-tools.eastus.cloudapp.azure.com'
export __RUNRICENV_DOCKER_IP__='137.135.91.204'
export __RUNRICENV_DOCKER_PORT__='10001'
export __RUNRICENV_DOCKER_USER__='docker'
export __RUNRICENV_DOCKER_PASS__='docker'

export __RUNRICENV_HELMREPO_HOST__='snapshot.helm.ranco-dev-tools.eastus.cloudapp.azure.com'
export __RUNRICENV_HELMREPO_PORT__='10001'
export __RUNRICENV_HELMREPO_IP__='137.135.91.204'
export __RUNRICENV_HELMREPO_USER__='helm'
export __RUNRICENV_HELMREPO_PASS__='helm'

