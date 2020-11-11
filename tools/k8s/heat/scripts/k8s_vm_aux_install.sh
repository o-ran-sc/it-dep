# this script installs AUX infrastructure components

# continue only on AUX cluster
CINDER_V_ID=$(cat /opt/config/cinder_volume_id.txt)
cat <<EOF > ./cinder_pv.yaml
apiVersion: "v1"
kind: "PersistentVolume"
metadata:
  name: "cinder-pv"
spec:
  capacity:
    storage: "5Gi"
  accessModes:
    - "ReadWriteOnce"
  cinder:
    fsType: "ext3"
    volumeID: "$CINDER_V_ID"
EOF
kubectl create -f ./cinder_pv.yaml


# install fluentd
LOGGING_NS="logging"
kubectl create namespace "${LOGGING_NS}"
while ! helm repo add incubator "https://kubernetes-charts-incubator.storage.googleapis.com/"; do
  sleep 10
done
IS_HELM3=$(helm version --short|grep -e "^v3")
HELM_FLAG='--name'
if [ -z $IS_HELM3 ]
   HELM_FLAG=""
fi

helm repo update
helm install ${HELM_FLAG} elasticsearch \
   --namespace "${LOGGING_NS}" \
   --set image.tag=6.7.0 \
   --set data.terminationGracePeriodSeconds=0 \
   --set master.persistence.enabled=false \
   --set data.persistence.enabled=false \
   incubator/elasticsearch 
helm install ${HELM_FLAG} fluentd \
   --namespace "${LOGGING_NS}" \
   --set elasticsearch.host=elasticsearch-client.${LOGGING_NS}.svc.cluster.local \
   --set elasticsearch.port=9200 \
   stable/fluentd-elasticsearch
helm install ${HELM_FLAG} kibana \
   --namespace "${LOGGING_NS}" \
   --set env.ELASTICSEARCH_URL=http://elasticsearch-client.${LOGGING_NS}.svc.cluster.local:9200 \
   --set env.ELASTICSEARCH_HOSTS=http://elasticsearch-client.${LOGGING_NS}.svc.cluster.local:9200 \
   --set env.SERVER_BASEPATH=/api/v1/namespaces/${LOGGING_NS}/services/kibana/proxy \
   stable/kibana
   #--set image.tag=6.4.2 \

KIBANA_POD_NAME=$(kubectl get pods --selector=app=kibana -n  "${LOGGING_NS}" \
   --output=jsonpath="{.items..metadata.name}")
wait_for_pods_running 1 "${LOGGING_NS}" "${KIBANA_POD_NAME}"


# install prometheus
PROMETHEUS_NS="monitoring"
OPERATOR_POD_NAME="prometheus-prometheus-operator-prometheus-0"
ALERTMANAGER_POD_NAME="alertmanager-prometheus-operator-alertmanager-0"
helm install ${HELM_FLAG} prometheus-operator  --namespace "${PROMETHEUS_NS}" stable/prometheus-operator
wait_for_pods_running 1 "${PROMETHEUS_NS}" "${OPERATOR_POD_NAME}"

GRAFANA_POD_NAME=$(kubectl get pods --selector=app=grafana -n  "${PROMETHEUS_NS}" \
   --output=jsonpath="{.items..metadata.name}")



cat <<EOF > ./ingress_lm.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-lm
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /kibana
        backend:
          serviceName: kibana
          servicePort: 5601
      - path: /operator
        backend:
          serviceName: prometheus-operator-prometheus 
          servicePort: 9090
      - path: /alertmanager
        backend:
          serviceName: prometheus-operator-alertmanager
          servicePort: 9093
      - path: /grafana
        backend:
          serviceName: prometheus-operator-grafana
          servicePort: 3000
EOF
kubectl apply -f ingress-lm.yaml

