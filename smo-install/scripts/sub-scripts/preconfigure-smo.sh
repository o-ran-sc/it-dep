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

# Check whether k8s is multinode or not and provide warning
if [ $(kubectl get nodes --no-headers | wc -l) -gt 1 ]; then
    echo "----------------------------------- WARNING!!! -------------------------------------------"
    echo "This is a multi-node cluster."
    echo "----------------------------------- Node Details  -----------------------------------------"
    kubectl get nodes
    echo "-------------------------------------------------------------------------------------------"
    echo "This installation uses /dockerdata-nfs as a volume mount point."
    echo "Each application creates its own sub-directory under /dockerdata-nfs."
    echo "-------------------------------------------------------------------------------------------"
    echo "If there is any previous installation, please ensure that the /dockerdata-nfs directory is empty."
    echo "Leaving any previous data in this directory may cause issues with the new installation."
    echo "-------------------------------------------------------------------------------------------"
    echo "The file permission of the sub-directory should be set to 777. "
    echo "Setting the permission to 777 is required for the application to work properly."
    echo "Hence, the following command should be run on all nodes in the cluster."
    echo "-------------------------------------------------------------------------------------------"
    echo "sudo mkdir -p /dockerdata-nfs/onap"
    echo "sudo mkdir -p /dockerdata-nfs/onap/mariadb"
    echo "sudo mkdir -p /dockerdata-nfs/onap/elastic-master-0"
    echo "sudo mkdir -p /dockerdata-nfs/onap/cps-temporal/data"
    echo "sudo mkdir -p /dockerdata-nfs/onap/strimzi-kafka/kafka-0"
    echo "sudo mkdir -p /dockerdata-nfs/onap/strimzi-kafka/zk-0"
    echo "sudo mkdir -p /dockerdata-nfs/onap/strimzi-kafka/controller-0"
    echo "sudo mkdir -p /dockerdata-nfs/onap/strimzi-kafka/broker-0"
    echo "sudo chmod -R 777 /dockerdata-nfs"
    echo "-------------------------------------------------------------------------------------------"
else
    echo "This is a single-node cluster."
    echo "The installation will proceed with the assumption that /dockerdata-nfs is available on this node."
    echo "------------------------------------- WARNING!!! -------------------------------------------"
    echo "If there is any previous installation, please ensure that the /dockerdata-nfs directory is empty."
    echo "Leaving any previous data in this directory may cause issues with the new installation."
    echo "-------------------------------------------------------------------------------------------"
fi

# This needs to be done on all nodes in case of multi-node setup
sudo mkdir -p /dockerdata-nfs/onap
sudo mkdir -p /dockerdata-nfs/onap/mariadb
sudo mkdir -p /dockerdata-nfs/onap/elastic-master-0
sudo mkdir -p /dockerdata-nfs/onap/cps-temporal/data
sudo mkdir -p /dockerdata-nfs/onap/strimzi-kafka/kafka-0
sudo mkdir -p /dockerdata-nfs/onap/strimzi-kafka/zk-0
sudo mkdir -p /dockerdata-nfs/onap/strimzi-kafka/controller-0
sudo mkdir -p /dockerdata-nfs/onap/strimzi-kafka/broker-0
sudo chmod -R 777 /dockerdata-nfs

# Mariadb operator installation
kubectl create ns mariadb-operator
helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator
helm repo update
helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds -n mariadb-operator
helm install mariadb-operator mariadb-operator/mariadb-operator -n mariadb-operator
kubectl wait deployment mariadb-operator -n mariadb-operator --for=condition=available --timeout=120s

# K8s Volume creation as required
kubectl apply -f ../packages/pre-configuration/mariadb-galera-pv.yaml








