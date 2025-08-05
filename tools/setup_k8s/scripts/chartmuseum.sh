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

# install chartmuseum via helm
helm install chartmuseum chartmuseum/chartmuseum --version $VERSION --namespace $Namespace --set service.type=NodePort 
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