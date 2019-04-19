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


export RICPLT_RELEASE_NAME='ric-full'
export RICPLT_NAMESPACE='ricplatform'
export RICXAPP_NAMESPACE='ricxapp'
export RICPLT_COMPONENTS="appmgr rtmgr dbaas e2mgr e2term"
export RICPLT_APPMGR_EXT_PORT="30099"
export RICPLT_E2MGR_EXT_PORT="30199"
export RICPLT_DASHBOARD_EXT_PORT="30080"
