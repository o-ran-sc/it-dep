# This document is the guide for the SMO Lite installation from scratch.

Install Kubernetes (v 1.32):

Instructions: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#kubectl-install-0

```bash
> sudo apt-get update

> sudo apt-get install docker docker.io 

> sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

> curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

> sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

> echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

> sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

> sudo apt-get update

> sudo apt-get install -y kubectl kubeadm kubelet

> sudo apt-get install containernetworking-plugins

> sudo apt-get install containerd

> kubeadm version

> kubelet --version

> kubectl version --client

> sudo swapoff -a

> sudo sed -i '/ swap / s/^\(.*\)$/#\1/' /etc/fstab

> sudo systemctl enable containerd

> sudo systemctl restart containerd

> sudo kubeadm init

> mkdir -p $HOME/.kube

> sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

> sudo chown $(id -u):$(id -g) $HOME/.kube/config

> kubectl get po -A

> kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

> kubectl get po -A

> kubectl taint nodes --all node-role.kubernetes.io/control-plane-

>   mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

> kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

> kubectl get po -A

> echo "apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer" |  kubectl create -f -

> kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

```

Nephio Installation (V4.0.0)

```bash
> wget -O - https://raw.githubusercontent.com/nephio-project/test-infra/v4.0.0/e2e/provision/init.sh |  \
sudo NEPHIO_DEBUG=false   \
     NEPHIO_BRANCH=v4.0.0 \
     NEPHIO_USER=<USERNAME>\
     K8S_CONTEXT=kubernetes-admin@kubernetes \
     bash

```

OAI Components installation:

> docker network create kind

> echo "deb [trusted=yes] https://netdevops.fury.site/apt/ /" | \
sudo tee -a /etc/apt/sources.list.d/netdevops.list

> sudo apt update && sudo apt install containerlab

> wget https://github.com/nephio-project/porch/releases/download/v4.0.0/porchctl_4.0.0_linux_amd64.tar.gz

> tar -xvf porchctl_4.0.0_linux_amd64.tar.gz

> sudo mv porchctl /usr/local/bin

Follow the instructions here, https://docs.nephio.org/docs/guides/user-guides/usecase-user-guides/exercise-2-oai/


SMO Installation:

Follow release mode installation from https://github.com/o-ran-sc/it-dep/tree/master/smo-install#o-ran-smo-package


Patch VES Collector:

Patch ves collector to allow 3gpp Rel-18 format 

```bash

kubectl patch deployment onap-dcae-ves-collector -n onap --type=json \
  -p='[{"op": "replace", "path": "/spec/template/spec/initContainers/0/command", "value": ["sh", "-c", "
  cp -R /opt/app/VESCollector/etc/. /opt/app/VESCollector/etc_rw/;
  rm /opt/app/VESCollector/etc_rw/externalRepo/schema-map.json;
  wget https://raw.githubusercontent.com/aravindtga/reactive-hibernate-many-to-many/refs/heads/master/schema-map.json -O /opt/app/VESCollector/etc_rw/externalRepo/schema-map.json;
  mkdir -p /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28104_MdaNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28104_MdaReport.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28105_AiMlNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28111_FaultNotifications.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28111_FaultNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28312_IntentExpectations.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28312_IntentNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28317_RanScNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28318_DsoNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28319_MsacNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28319_MsacNrm -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28531_NSProvMnS.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28531_NSSProvMnS.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28532_FileDataReportingMnS.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28532_HeartbeatNtf.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28532_PerfMnS.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28532_ProvMnS.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28532_StreamingDataMnS.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28536_CoslaNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28538_EdgeNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28541_5GcNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28541_NrNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28541_SliceNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28550_PerfMeasJobCtrlMnS.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28623_ComDefs.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28623_FileManagementNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28623_GenericNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28623_ManagementDataCollectionNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28623_MnSRegistryNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28623_PmControlNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28623_QoEMeasurementCollectionNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28623_SubscriptionControlNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28623_ThresholdMonitorNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS28623_TraceControlNrm.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/; 
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS29512_Npcf_SMPolicyControl.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS29514_Npcf_PolicyAuthorization.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS29520_Nnwdaf_AnalyticsInfo.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS29520_Nnwdaf_EventsSubscription.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
wget https://forge.3gpp.org/rep/sa5/MnS/-/raw/Rel-18/OpenAPI/TS29571_CommonData.yaml -P /opt/app/VESCollector/etc_rw/externalRepo/3gpp/rep/sa5/MnS/blob/Rel-18/OpenAPI/;
  "]}]'

```


Patch RANPM - DFC

DFC should be configured to work with TS28623 format

> Edit DFC config map named "dfc-cm" in SMO namespace to have the following value in application.yaml
>> app.file-ready-message-class: TS28623

Restart the DFC 

Patch RANPM - Pmlogger and PM producer

> Edit the PMLogger config map named "pmlog-job-cm" in SMO namespace to have the following value in jobDefinition.json
```json
{
   "info_type_id": "PmData",
   "job_owner": "console",
   "job_definition": {
      "filter": {
         "sourceNames": [],
         "measObjInstIds": [],
         "measTypeSpecs": [
            {
               "measuredObjClass": "CellId"
            }
         ],
         "measuredEntityDns": []
      },
      "deliveryInfo": {
         "topic": "pmreports",
         "bootStrapServers": "onap-strimzi-kafka-bootstrap.onap:9095"
      }
   }
}
```
Restart the PMLogger


Install O1 Adapter

Clone the O1 adapter repo and build the image

```bash
git clone https://gitlab.eurecom.fr/oai/o1-adapter
cd o1-adapter
> ./build-adapter.sh --adapter 
```
Push this to any registry to use in the docker-compose file

Sample docker-compose file for O1 adapter and use the image built above(aravindtga/o1adaptor:2.0.0).
This sample should be created inside the docker folder of the O1 adapter repo.

```bash
```yaml
services:
  o1-oai-adapter:
    container_name: o1-oai-adapter
    image: oai/o1-adapter:latest
    ports:
      - "1830:830"
      - "1222:22"
    labels:
      app: "o1-oai-adapter"
      deploy: "o1-oai-adapter-deployment"
    volumes:
      - ./.ftp:/ftp
      - ./config:/adapter/config/
```
Update the telnet, VES Collector and netconf configuration in the file docker/config/config.json.
Sample config.json file is provided in the repo.

```json
{
    "log-level": 3,
    "software-version": "latest",
    "network": {
        "host": "HOST",
        "username": "netconf",
        "password": "netconf!",
        "netconf-port": 1830,
        "sftp-port": 122
    },

    "ves": {
        "template": {
            "new-alarm": "config/ves-new-alarm.json",
            "clear-alarm": "config/ves-clear-alarm.json",
            "pnf-registration": "config/ves-pnf-registration.json",
            "file-ready": "config/ves-file-ready.json",
            "heartbeat": "config/ves-heartbeat.json",
            "pm-data": "config/pmData-measData.xml"
        },

        "pnf-registration": true,
        "heartbeat-interval": 90,
        "url": "http://VES_COLLECTOR_HOST:8080/eventListener/v7",
        "username":"sample1",
        "password":"sample1",
        "pm-data-interval": 900,
        "file-expiry": 86400
    },

    "alarms": {
        "internal-connection-lost-timeout": 3,
        "load-downlink-exceeded-warning-threshold": 50,
        "load-downlink-exceeded-warning-timeout": 15
    },

    "telnet": {
        "host": "DU_TELNET_HOST",
        "port": 9090
    },

    "info": {
        "gnb-du-id": 3584,
        "cell-local-id": 0,
        "node-id": "gNB-Eurecom-5GNRBox-00001",
        "location-name": "MountPoint 05, Rack 234-17, Room 234, 2nd Floor, Körnerstraße 7, 10785 Berlin, Germany, Europe, Earth, Solar-System, Universe",
        "managed-by": "ManagementSystem=O-RAN-SC-ONAP-based-SMO",
        "managed-element-type": "NodeB",
        "model": "nr-softmodem",
        "unit-type": "gNB"
    }
}
```
Update the docker/config/ves-file-ready.json to have the below (This should match with the Topic on which DFC listening for file-ready events),

```json
"stndDefinedNamespace": "notification"
```

Update the docker/config/pmData-measData.xml to have the below,

```xml
...
<measInfo measInfoId="PM=1,PmGroup=GNBDU">
                        <job jobId="1"/>
                        <granPeriod duration="PT@log-period@S" endTime="@end-time@"/>
                        <repPeriod duration="P1D"/>
                        <measType p="1">DRB.MeanActiveUeDl</measType>
                        <measType p="2">DRB.MaxActiveUeDl</measType>
                        <measType p="3">DRB.MeanActiveUeUl</measType>
                        <measType p="4">DRB.MaxActiveUeUl</measType>
                        <measType p="5">RRU.PrbTotDl</measType>
                        <measType p="6">DRB.UEThpDl</measType>
                        <measType p="7">DRB.UEThpUl</measType>
                        <measType p="8">PEE.AvgPower</measType>
                        <measValue measObjLdn="DuFunction=@du-id@,CellId=@cell-id@">
                                <r p="1">@mean-active-ue@</r>
                                <r p="2">@max-active-ue@</r>
                                <r p="3">@mean-active-ue@</r>
                                <r p="4">@max-active-ue@</r>
                                <r p="5">@load-avg@</r>
                                <r p="6">@ue-thp-dl@</r>
                                <r p="7">@ue-thp-ul@</r>
                                <r p="8">@pee-avg-pwr@</r>
                        </measValue>
                </measInfo>
...                
```

Start the O1 adapter using docker-compose

```bash
docker-compose up -d
```

This should start the O1 adapter. O1 adapter is connected to the DU using telnet and to the VES collector using HTTP. The O1 adapter will send the file-ready event to the VES collector based on the configuration in the config.json file.


Once this is completed, You should be able to see the DU information in the SDNC WEB. RANPM components should process the PM data and that can be seen in influxdb UI.




Cleanup:

```bash
> sudo kubeadm reset -f
> sudo systemctl stop kubelet
> sudo systemctl stop containerd

>sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/kubelet
sudo rm -rf /var/lib/cni
sudo rm -rf /opt/cni
sudo rm -rf /etc/cni
sudo rm -rf /var/run/kubernetes
sudo rm -rf /opt/cni/bin
sudo rm -rf /etc/cni/net.d


> sudo ip link delete cni0 || true
sudo ip link delete flannel.1 || true
sudo ip link delete docker0 || true
sudo ip link delete cilium_host || true
sudo ip link delete cilium_net || true
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

> sudo rm -rf /var/lib/containerd

> rm -rf ~/.kube

> sudo rm -rf /opt/containerd/ /opt/local-path-provisioner/

> sudo apt-get remove -y docker docker.io containerd containernetworking-plugins kubectl kubeadm kubelet containerlab

> sudo rm /etc/apt/keyrings/kubernetes-apt-keyring.gpg /etc/apt/sources.list.d/kubernetes.list

```