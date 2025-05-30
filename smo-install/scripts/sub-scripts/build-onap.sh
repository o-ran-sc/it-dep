#!/bin/bash

###
# ============LICENSE_START=======================================================
# ORAN SMO Package
# ================================================================================
# Copyright (C) 2021 AT&T Intellectual Property. All rights reserved.
# Copyright (C) 2024 OpenInfra Foundation Europe. All rights reserved.
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
# ===================================================================
# 
###

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")
cd $SCRIPT_PATH

sudo apt-get install make -y

helm plugin install ../../onap_oom/kubernetes/helm/plugins/undeploy/
helm plugin install ../../onap_oom/kubernetes/helm/plugins/deploy/

echo '### Building ONAP part###'
(cd ../../onap_oom/kubernetes && make all -e SKIP_LINT=TRUE)
