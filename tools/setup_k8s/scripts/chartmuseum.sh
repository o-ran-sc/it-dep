#!/bin/bash
################################################################################
#   Copyright (c) 2025 Broadband Multimedia Wireless Lab, NTUST                #
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

echo "***************************************************************************************************************"
echo "						Installing Chartmuseum						"
echo "***************************************************************************************************************"

Namespace=chartmuseum
VERSION=3.10.4

# Create a dedicated namespace
kubectl create namespace $Namespace

# Add the ChartMuseum Helm repository
helm repo add chartmuseum https://chartmuseum.github.io/charts
helm repo update

# install chartmuseum via helm. Requires local storageClass first
helm install chartmuseum chartmuseum/chartmuseum \
    --version $VERSION \
    --namespace $Namespace \
	  --set service.type=NodePort \
  	--set env.open.DISABLE_API=false \
  	--set env.open.ALLOW_OVERWRITE=true \
  	--set env.open.STORAGE=local \
  	--set persistence.enabled=true

NODE_PORT=$(kubectl get --namespace $Namespace -o jsonpath="{.spec.ports[0].nodePort}" services chartmuseum)
NODE_IP=$(kubectl get nodes --namespace $Namespace -o jsonpath="{.items[0].status.addresses[0].address}")
HELM_REPO_URL="http://${NODE_IP}:${NODE_PORT}"

for i in {1..60}; do # Try for up to 60 seconds (1 minute)
    # curl -sSf will be silent, show errors, and fail on HTTP errors (e.g., 404).
    if curl -sSf "${HELM_REPO_URL}/index.yaml" > /dev/null; then
        echo "ChartMuseum is ready! Took $((i)) seconds."
        break
    fi
    echo "Still waiting for ChartMuseum..."
    sleep 1
done
# Check if the loop finished without finding the service
if [ $i -eq 60 ]; then
  echo "Error: ChartMuseum never became available at ${HELM_REPO_URL}"
  exit 1
fi

echo "ChartMuseum is available at: ${HELM_REPO_URL}"
# Use the URL to add the repo and push the chart
helm repo add local "${HELM_REPO_URL}"
helm repo update

echo "***************************************************************************************************************"
echo "						Installing Chartmuseum-Plugins						"
echo "***************************************************************************************************************"

TAR_VERSION=v0.10.3
echo "Downloading and installing helm-push ${TAR_VERSION} ..."
TAR_FILE=helm-push-${TAR_VERSION}.tar.gz
HELM_PLUGINS=$(helm env HELM_PLUGINS)
mkdir -p $HELM_PLUGINS/helm-push
cd $HELM_PLUGINS/helm-push
wget https://nexus.o-ran-sc.org/content/repositories/thirdparty/chartmuseum/helm-push/$TAR_VERSION/$TAR_FILE
tar zxvf $TAR_FILE >/dev/null
rm $TAR_FILE
