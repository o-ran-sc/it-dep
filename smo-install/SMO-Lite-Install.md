# This document is the guide for the SMO Lite installation from scratch(Nephio, SMO, OAI Components,O1-Adapter).

This guide describe the steps to install the SMO environment which involves Nephio, SMO, OAI components and OAI O1 Adapter on a Non-Kind cluster.

## Pre-requisites
- Ubuntu 22.04 LTS
- 64GB RAM, 20 vCPUs, 100GB disk space

## System update
```bash
> sudo apt-get update

> sudo apt-get upgrade -y
```

## Docker installation
```bash
> sudo apt-get install docker docker.io  -y
```

## Kubernetes installation
```bash
> git clone --recursive "https://gerrit.o-ran-sc.org/r/it/dep"

> sudo ./dep/tools/setup_k8s/setup_k8s.sh

> sudo usermod -aG docker $USER

> sudo chown -R ubuntu:ubuntu .kube

```

## Docker hub pull limit handling

Repeated installations can hit Docker Hub pull limits. You can avoid this by adding Docker Hub credentials in the containerd config like below in '/etc/containerd/config.toml':

> Docker Hub pull limits vary based on the account type. Usage and pull limits can be checked at https://docs.docker.com/docker-hub/usage/

```toml
...
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."docker.io".auth]
          username = ""
          password = ""
        [plugins."io.containerd.grpc.v1.cri".registry.configs."registry-1.docker.io".auth]
          username = ""
          password = ""
...
```

## CSI installation
This installs a minimal OpenEBS setup with only the hostpath storage class. It will be used for the Nephio and SMO installation.

```bash
> helm repo add openebs https://openebs.github.io/openebs

> helm repo update

> helm upgrade --install openebs --namespace openebs openebs/openebs --version 4.3.0 --create-namespace --set engines.replicated.mayastor.enabled=false --set engines.local.lvm.enabled=false --set engines.local.zfs.enabled=false --set loki.enabled=false --set alloy.enabled=false --wait

> kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```


## Nephio Installation (V4.0.0)(Non-Kind cluster)

```bash
> wget -O - https://raw.githubusercontent.com/nephio-project/test-infra/v4.0.0/e2e/provision/init.sh |  \
sudo NEPHIO_DEBUG=false   \
     NEPHIO_BRANCH=v4.0.0 \
     NEPHIO_USER=ubuntu \
     K8S_CONTEXT=kubernetes-admin@kubernetes \
     bash
```

## OAI Components installation

OAI components are installed using Nephio.

```bash
> docker network create kind

> echo "deb [trusted=yes] https://netdevops.fury.site/apt/ /" | \
sudo tee -a /etc/apt/sources.list.d/netdevops.list

> sudo apt update && sudo apt install containerlab

> wget https://github.com/nephio-project/porch/releases/download/v4.0.0/porchctl_4.0.0_linux_amd64.tar.gz

> tar -xvf porchctl_4.0.0_linux_amd64.tar.gz

> sudo mv porchctl /usr/local/bin
```

Follow the instructions here, https://docs.nephio.org/docs/guides/user-guides/usecase-user-guides/exercise-2-oai/


## SMO Installation

Follow release mode installation from https://github.com/o-ran-sc/it-dep/tree/master/smo-install#o-ran-smo-package


### Patch RANPM - DFC

DFC should be configured to work with TS28623 format.

Edit DFC config map named "dfc-cm" in SMO namespace to have the following value in application.yaml
```yaml
app:
  file-ready-message-class: TS28623
```
Restart the DFC.

### Patch RANPM - Pmlogger and PM producer

Edit the PMLogger config map named "pmlog-job-cm" in SMO namespace to have the following value in jobDefinition.json

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
Restart the PMLogger.


## O1 Adapter Installation

Clone the O1 adapter repo and build the image

```bash
> git clone https://gitlab.eurecom.fr/oai/o1-adapter

> cd o1-adapter

> ./build-adapter.sh --adapter
```
Push this to any registry to use in the docker-compose file

This sample should be created inside the docker folder of the O1 adapter repo.

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
Update the telnet, VES Collector and netconf configuration in the file 'docker/config/config.json'.
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
        "sftp-port": 1222
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
> docker-compose up -d
```

This should start the O1 adapter. O1 adapter is connected to the DU using telnet and to the VES collector using HTTP. The O1 adapter will send the file-ready event to the VES collector based on the configuration in the config.json file.


Once this is completed, You should be able to see the DU information in the SDNC WEB. RANPM components should process the PM data and that can be seen in influxdb UI.


## Cleanup

Please follow the SMO uninstallation steps from https://github.com/o-ran-sc/it-dep/tree/master/smo-install#o-ran-smo-package.

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

> sudo rm -rf /opt/containerd/

> sudo apt-get remove -y docker docker.io containerd containernetworking-plugins kubectl kubeadm kubelet containerlab

> sudo rm /etc/apt/keyrings/kubernetes-apt-keyring.gpg /etc/apt/sources.list.d/kubernetes.list

```