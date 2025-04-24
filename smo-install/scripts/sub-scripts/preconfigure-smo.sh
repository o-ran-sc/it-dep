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

# This needs to be done on all nodes in case of multi-node setup
sudo mkdir -p /dockerdata-nfs/onap
sudo mkdir -p /dockerdata-nfs/onap/mariadb
sudo mkdir -p /dockerdata-nfs/onap/elastic-master-0
sudo chmod -R 777 /dockerdata-nfs

# Mariadb operator installation
kubectl create ns mariadb-operator
helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator
helm repo update
helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds
helm install mariadb-operator mariadb-operator/mariadb-operator
kubectl wait deployment mariadb-operator -n mariadb-operator --for=condition=available --timeout=120s

# K8s Volume creation as required
kubectl apply -f ../packages/pre-configuration/mariadb-galera-pv.yaml

# Modify the volume permission as required
# kubectl apply -f ../packages/pre-configuration/volume-permission-init.yaml

# #Wait for volume permission init job to complete
# kubectl wait job.batch/volume-permission-init --for condition=complete --timeout 300s

# #Delete the job and pvc
# kubectl delete job volume-permission-init
# kubectl delete pvc mariadb-galera-pvc

# #Patch the PV to be available for next use
# kubectl patch pv mariadb-galera-pv -p '{"spec":{"claimRef": null}}'







