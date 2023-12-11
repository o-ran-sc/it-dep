#!/bin/bash

###
# ============LICENSE_START=======================================================
# ORAN SMO Package
# ================================================================================
# Copyright (C) 2021 AT&T Intellectual Property. All rights
#                             reserved.
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
#Helm package
cd /tmp
wget https://get.helm.sh/helm-v3.12.3-linux-amd64.tar.gz
tar xvfz /tmp/helm-v3.12.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
sudo apt-get install git -y


echo "Checking HELM ..."
helm version

TAR_VERSION=v0.10.3
echo "Downloading and installing helm-push ${TAR_VERSION} ..."
TAR_FILE=helm-push-${TAR_VERSION}.tar.gz
HELM_PLUGINS=$(helm env HELM_PLUGINS)
mkdir -p $HELM_PLUGINS/helm-push
cd $HELM_PLUGINS/helm-push
wget https://nexus.o-ran-sc.org/content/repositories/thirdparty/chartmuseum/helm-push/$TAR_VERSION/$TAR_FILE
tar zxvf $TAR_FILE >/dev/null
rm $TAR_FILE
cd /tmp/
helm repo remove local
helm repo add local http://localhost:18080
