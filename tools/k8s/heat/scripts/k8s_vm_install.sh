#!/bin/bash -x
################################################################################
#   Copyright (c) 2019,2020 AT&T Intellectual Property.                        #
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


# first parameter: number of expected running  pods
# second parameter: namespace (all-namespaces means all namespaces)
# third parameter: [optional] keyword
wait_for_pods_running () {
  NS="$2"
  CMD="kubectl get pods --all-namespaces "
  if [ "$NS" != "all-namespaces" ]; then
    CMD="kubectl get pods -n $2 "
  fi
  KEYWORD="Running"
  if [ "$#" == "3" ]; then
    KEYWORD="${3}.*Running"
  fi

  CMD2="$CMD | grep \"$KEYWORD\" | wc -l"
  NUMPODS=$(eval "$CMD2")
  echo "waiting for $NUMPODS/$1 pods running in namespace [$NS] with keyword [$KEYWORD]"
  while [  $NUMPODS -lt $1 ]; do
    sleep 5
    NUMPODS=$(eval "$CMD2")
    echo "> waiting for $NUMPODS/$1 pods running in namespace [$NS] with keyword [$KEYWORD]"
  done 
}


# first parameter: interface name
start_ipv6_if () {
  # enable ipv6 interface
  # standard Ubuntu cloud image does not have dual interface configuration or ipv6
  IPv6IF="$1"
  if ifconfig -a $IPv6IF; then
    echo "" >> /etc/network/interfaces.d/50-cloud-init.cfg
    echo "allow-hotplug ${IPv6IF}" >> /etc/network/interfaces.d/50-cloud-init.cfg
    echo "iface ${IPv6IF} inet6 auto" >> /etc/network/interfaces.d/50-cloud-init.cfg
    ifconfig ${IPv6IF} up
  fi
}

echo "k8s_vm_install.sh"
set -x
export DEBIAN_FRONTEND=noninteractive
echo "__host_private_ip_addr__ $(hostname)" >> /etc/hosts
printenv

IPV6IF=""

rm -rf /opt/config
mkdir -p /opt/config
echo "__docker_version__" > /opt/config/docker_version.txt
echo "__k8s_version__" > /opt/config/k8s_version.txt
echo "__k8s_cni_version__" > /opt/config/k8s_cni_version.txt
echo "__helm_version__" > /opt/config/helm_version.txt
echo "__host_private_ip_addr__" > /opt/config/host_private_ip_addr.txt
echo "__k8s_mst_floating_ip_addr__" > /opt/config/k8s_mst_floating_ip_addr.txt
echo "__k8s_mst_private_ip_addr__" > /opt/config/k8s_mst_private_ip_addr.txt
echo "__mtu__" > /opt/config/mtu.txt
echo "__cinder_volume_id__" > /opt/config/cinder_volume_id.txt
echo "__stack_name__" > /opt/config/stack_name.txt

# assume we are setting up AUX cluster VM if hostname contains "aux"
ISAUX='false'
if [[ $(cat /opt/config/stack_name.txt) == *aux* ]]; then
  ISAUX='true'
fi

modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
modprobe -- nf_conntrack_ipv6
modprobe -- nf_conntrack_proto_sctp

if [ ! -z "$IPV6IF" ]; then
  start_ipv6_if $IPV6IF
fi

# disable swap
#SWAPFILES=$(grep swap /etc/fstab | sed '/^[ \t]*#/ d' |cut -f1 -d' ')
SWAPFILES=$(grep swap /etc/fstab | sed '/^[ \t]*#/ d' | sed 's/[\t ]/ /g' | tr -s " " | cut -f1 -d' ')
if [ ! -z $SWAPFILES ]; then
  for SWAPFILE in $SWAPFILES
  do
    if [ ! -z $SWAPFILE ]; then
      echo "disabling swap file $SWAPFILE"
      if [[ $SWAPFILE == UUID* ]]; then
        UUID=$(echo $SWAPFILE | cut -f2 -d'=')
        swapoff -U $UUID
      else
        swapoff $SWAPFILE
      fi
      sed -i "\%$SWAPFILE%d" /etc/fstab
    fi
  done
fi


DOCKERV=$(cat /opt/config/docker_version.txt)
KUBEV=$(cat /opt/config/k8s_version.txt)
KUBECNIV=$(cat /opt/config/k8s_cni_version.txt)

KUBEVERSION="${KUBEV}-00"
CNIVERSION="${KUBECNIV}-00"
DOCKERVERSION="${DOCKERV}"

# adjust package version tag
UBUNTU_RELEASE=$(lsb_release -r | sed 's/^[a-zA-Z:\t ]\+//g')
if [[ ${UBUNTU_RELEASE} == 16.* ]]; then
  echo "Installing on Ubuntu $UBUNTU_RELEASE (Xenial Xerus) host"
  if [ ! -z "${DOCKERV}" ]; then
    DOCKERVERSION="${DOCKERV}-0ubuntu1~16.04.5"
  fi
elif [[ ${UBUNTU_RELEASE} == 18.* ]]; then
  echo "Installing on Ubuntu $UBUNTU_RELEASE (Bionic Beaver)"
  if [ ! -z "${DOCKERV}" ]; then
    DOCKERVERSION="${DOCKERV}-0ubuntu1~18.04.4"
  fi
else
  echo "Unsupported Ubuntu release ($UBUNTU_RELEASE) detected.  Exit."
  exit
fi


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list

# tell apt to retry 3 times if failed
mkdir -p /etc/apt/apt.conf.d
echo "APT::Acquire::Retries \"3\";" > /etc/apt/apt.conf.d/80-retries

# install low latency kernel, docker.io, and kubernetes
apt-get update
RES=$(apt-get install -y virt-what curl jq netcat make ipset moreutils 2>&1)
if [[ $RES == */var/lib/dpkg/lock* ]]; then
  echo "Fail to get dpkg lock.  Wait for any other package installation"
  echo "process to finish, then rerun this script"
  exit -1
fi

if ! echo $(virt-what) | grep "virtualbox"; then
  # this version of low latency kernel causes virtualbox VM to hang.
  # install if identifying the VM not being a virtualbox VM.
  apt-get install -y linux-image-4.15.0-45-lowlatency
fi

APTOPTS="--allow-downgrades --allow-change-held-packages --allow-unauthenticated --ignore-hold "

# remove infrastructure stack if present
# note the order of the packages being removed.
for PKG in kubeadm docker.io; do
  INSTALLED_VERSION=$(dpkg --list |grep ${PKG} |tr -s " " |cut -f3 -d ' ')
  if [ ! -z ${INSTALLED_VERSION} ]; then
    if [ "${PKG}" == "kubeadm" ]; then
      kubeadm reset -f
      rm -rf ~/.kube
      apt-get -y $APTOPTS remove kubeadm kubelet kubectl kubernetes-cni
    else
      apt-get -y $APTOPTS remove "${PKG}"
    fi
  fi
done
apt-get -y autoremove

# install docker
if [ -z ${DOCKERVERSION} ]; then
  apt-get install -y $APTOPTS docker.io
else
  apt-get install -y $APTOPTS docker.io=${DOCKERVERSION}
fi
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
systemctl enable docker.service
systemctl daemon-reload
systemctl restart docker

if [ -z ${CNIVERSION} ]; then
  apt-get install -y $APTOPTS kubernetes-cni
else
  apt-get install -y $APTOPTS kubernetes-cni=${CNIVERSION}
fi

if [ -z ${KUBEVERSION} ]; then
  apt-get install -y $APTOPTS kubeadm kubelet kubectl
else
  apt-get install -y $APTOPTS kubeadm=${KUBEVERSION} kubelet=${KUBEVERSION} kubectl=${KUBEVERSION}
fi

apt-mark hold docker.io kubernetes-cni kubelet kubeadm kubectl


# test access to k8s docker registry
kubeadm config images pull --kubernetes-version=${KUBEV}


NODETYPE="master"
# non-master nodes have hostnames ending with -[0-9][0-9]
if [ "$NODETYPE" == "master" ]; then
  # below are steps for initializating master node, only run on the master node.  
  # minion node join will be triggered from the caller of the stack creation as ssh command.

  # create kubenetes config file
  if [[ ${KUBEV} == 1.13.* ]]; then
    cat <<EOF >/root/config.yaml
apiVersion: kubeadm.k8s.io/v1alpha3
kubernetesVersion: v${KUBEV}
kind: ClusterConfiguration
apiServerExtraArgs:
  feature-gates: SCTPSupport=true
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF

  elif [[ ${KUBEV} == 1.14.* ]]; then
    cat <<EOF >/root/config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kubernetesVersion: v${KUBEV}
kind: ClusterConfiguration
apiServerExtraArgs:
  feature-gates: SCTPSupport=true
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF
  elif [[ ${KUBEV} == 1.15.* ]] || [[ ${KUBEV} == 1.16.* ]] || [[ ${KUBEV} == 1.18.* ]]; then
    cat <<EOF >/root/config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kubernetesVersion: v${KUBEV}
kind: ClusterConfiguration
apiServer:
  extraArgs:
    feature-gates: SCTPSupport=true
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
EOF
  else
    echo "Unsupported Kubernetes version requested.  Bail."
    exit
  fi

  # create a RBAC file for helm (tiller)
  cat <<EOF > /root/rbac-config.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOF


  # start cluster (make sure CIDR is enabled with the flag)
  kubeadm init --config /root/config.yaml

  # set up kubectl credential and config
  cd /root
  rm -rf .kube
  mkdir -p .kube
  cp -i /etc/kubernetes/admin.conf /root/.kube/config
  chown root:root /root/.kube/config
  export KUBECONFIG=/root/.kube/config
  echo "KUBECONFIG=${KUBECONFIG}" >> /etc/environment

  # at this point we should be able to use kubectl
  kubectl get pods --all-namespaces

  # install flannel
  kubectl apply -f "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"

  # waiting for all 8 kube-system pods to be in running state
  # (at this point, minions have not joined yet)
  wait_for_pods_running 8 kube-system

  # if running a single node cluster, need to enable master node to run pods
  kubectl taint nodes --all node-role.kubernetes.io/master-

  # install Helm
  HELMV=$(cat /opt/config/helm_version.txt)
  HELMVERSION=${HELMV}
  if [ ! -e helm-v${HELMVERSION}-linux-amd64.tar.gz ]; then
    wget https://get.helm.sh/helm-v${HELMVERSION}-linux-amd64.tar.gz
  fi
  cd /root && rm -rf Helm && mkdir Helm && cd Helm
  tar -xvf ../helm-v${HELMVERSION}-linux-amd64.tar.gz
  mv linux-amd64/helm /usr/local/bin/helm

  cd /root
  # install RBAC for Helm
  if [[ ${HELMVERSION} == 2.* ]]; then
     kubectl create -f rbac-config.yaml
  fi

  rm -rf /root/.helm
  if [[ ${KUBEV} == 1.16.* ]]; then
    # helm init uses API extensions/v1beta1 which is depreciated by Kubernetes
    # 1.16.0.  Until upstream (helm) provides a fix, this is the work-around.
    if [[ ${HELMVERSION} == 2.* ]]; then
       helm init --service-account tiller --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml > /tmp/helm-init.yaml
       sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' /tmp/helm-init.yaml > /tmp/helm-init-patched.yaml
       kubectl apply -f /tmp/helm-init-patched.yaml
    fi
  else
    if [[ ${HELMVERSION} == 2.* ]]; then
       helm init --service-account tiller
    fi
  fi
  if [[ ${HELMVERSION} == 2.* ]]; then
     helm init -c
     export HELM_HOME="$(pwd)/.helm"
     echo "HELM_HOME=${HELM_HOME}" >> /etc/environment
  fi

  # waiting for tiller pod to be in running state
  while ! helm version; do
    echo "Waiting for Helm to be ready"
    sleep 15
  done

  echo "Preparing a master node (lowser ID) for using local FS for PV"
  PV_NODE_NAME=$(kubectl get nodes |grep master | cut -f1 -d' ' | sort | head -1)
  kubectl label --overwrite nodes $PV_NODE_NAME local-storage=enable
  if [ "$PV_NODE_NAME" == "$(hostname)" ]; then
    mkdir -p /opt/data/dashboard-data
  fi

  echo "Done with master node setup"
fi


# add rancodev CI tool hostnames
if [[ ! -z "${__RUNRICENV_GERRIT_IP__}" && ! -z "${__RUNRICENV_GERRIT_HOST__}" ]]; then 
  echo "${__RUNRICENV_GERRIT_IP__} ${__RUNRICENV_GERRIT_HOST__}" >> /etc/hosts
fi
if [[ ! -z "${__RUNRICENV_DOCKER_IP__}" && ! -z "${__RUNRICENV_DOCKER_HOST__}" ]]; then 
  echo "${__RUNRICENV_DOCKER_IP__} ${__RUNRICENV_DOCKER_HOST__}" >> /etc/hosts
fi
if [[ ! -z "${__RUNRICENV_HELMREPO_IP__}" && ! -z "${__RUNRICENV_HELMREPO_HOST__}" ]]; then 
  echo "${__RUNRICENV_HELMREPO_IP__} ${__RUNRICENV_HELMREPO_HOST__}" >> /etc/hosts
fi

if [[ "${__RUNRICENV_HELMREPO_CERT_LEN__}" -gt "100" ]]; then
  cat <<EOF >/etc/ca-certificates/update.d/helm.crt
${__RUNRICENV_HELMREPO_CERT__}
EOF
fi

# add cert for accessing docker registry in Azure
if [[ "${__RUNRICENV_DOCKER_CERT_LEN__}" -gt "100" ]]; then
  mkdir -p /etc/docker/certs.d/${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}
  cat <<EOF >/etc/docker/ca.crt
${__RUNRICENV_DOCKER_CERT__}
EOF
  cp /etc/docker/ca.crt /etc/docker/certs.d/${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}/ca.crt

  service docker restart
  systemctl enable docker.service
  docker login -u ${__RUNRICENV_DOCKER_USER__} -p ${__RUNRICENV_DOCKER_PASS__} ${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}
  docker pull ${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}/whoami:0.0.1
fi

if [ "$(uname -r)" != "4.15.0-45-lowlatency" ]; then reboot; fi
