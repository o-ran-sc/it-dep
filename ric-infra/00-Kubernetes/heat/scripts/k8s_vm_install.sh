#!/bin/bash -x
################################################################################
#   Copyright (c) 2019 AT&T Intellectual Property.                             #
#   Copyright (c) 2019 Nokia.                                                  #
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


# first parameter: number of expected running pods
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
    #echo "auto ${IPv6IF}" >> /etc/network/interfaces.d/50-cloud-init.cfg
    echo "allow-hotplug ${IPv6IF}" >> /etc/network/interfaces.d/50-cloud-init.cfg
    echo "iface ${IPv6IF} inet6 auto" >> /etc/network/interfaces.d/50-cloud-init.cfg
    #dhclient -r $IPv6IF
    #systemctl restart networking
    ifconfig ${IPv6IF} up
  fi
}

echo "k8s_vm_install.sh"
set -x
export DEBIAN_FRONTEND=noninteractive
echo "__host_private_ip_addr__ $(hostname)" >> /etc/hosts
printenv

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

start_ipv6_if ens4

# disable swap
SWAPFILES=$(grep swap /etc/fstab | sed '/^#/ d' |cut -f1 -d' ')
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
      # edit /etc/fstab file, remove line with /swapfile
      sed -i -e "/$SWAPFILE/d" /etc/fstab
    fi
  done
fi
# disable swap
#swapoff /swapfile
# edit /etc/fstab file, remove line with /swapfile
#sed -i -e '/swapfile/d' /etc/fstab


DOCKERV=$(cat /opt/config/docker_version.txt)
KUBEV=$(cat /opt/config/k8s_version.txt)
KUBECNIV=$(cat /opt/config/k8s_cni_version.txt)

KUBEVERSION="${KUBEV}-00"
CNIVERSION="${KUBECNIV}-00"
DOCKERVERSION="${DOCKERV}"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list

# install low latency kernel, docker.io, and kubernetes
apt-get update
apt-get install -y linux-image-4.15.0-45-lowlatency curl jq netcat docker.io=${DOCKERVERSION}
apt-get install -y kubernetes-cni=${CNIVERSION}
apt-get install -y --allow-unauthenticated kubeadm=${KUBEVERSION} kubelet=${KUBEVERSION} kubectl=${KUBEVERSION}
apt-mark hold docker.io kubernetes-cni kubelet kubeadm kubectl


# test access to k8s docker registry
kubeadm config images pull


# non-master nodes have hostnames ending with -[0-9][0-9]
if [[ $(hostname) == *-[0-9][0-9] ]]; then
  echo "Done for non-master node"
  echo "Starting an NC TCP server on port 29999 to indicate we are ready"
  nc -l -p 29999 &
else 
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


  # install Helm
  HELMV=$(cat /opt/config/helm_version.txt)
  HELMVERSION=${HELMV}
  cd /root
  mkdir Helm
  cd Helm
  wget https://storage.googleapis.com/kubernetes-helm/helm-v${HELMVERSION}-linux-amd64.tar.gz
  tar -xvf helm-v${HELMVERSION}-linux-amd64.tar.gz
  mv linux-amd64/helm /usr/local/bin/helm

  # set up kubectl credential and config
  cd /root
  rm -rf .kube
  mkdir -p .kube
  cp -i /etc/kubernetes/admin.conf /root/.kube/config
  chown root:root /root/.kube/config

  # at this point we should be able to use kubectl
  kubectl get pods --all-namespaces

  # install flannel
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml


  # waiting for all 8 kube-system pods to be in running state
  # (at this point, minions have not joined yet)
  wait_for_pods_running 8 kube-system

  # if running a single node cluster, need to enable master node to run pods
  kubectl taint nodes --all node-role.kubernetes.io/master-

  cd /root
  # install RBAC for Helm
  kubectl create -f rbac-config.yaml


  rm -rf /root/.helm
  helm init --service-account tiller
  export HELM_HOME="/root/.helm"

  # waiting for tiller pod to be in running state
  wait_for_pods_running 1 kube-system tiller-deploy

  while ! helm version; do
    echo "Waiting for Helm to be ready"
    sleep 15
  done


  echo "Starting an NC TCP server on port 29999 to indicate we are ready"
  nc -l -p 29999 &

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

if [ ! -z "${__RUNRICENV_HELMREPO_CERT__}" ]; then
  cat <<EOF >/etc/ca-certificates/update.d/helm.crt
${__RUNRICENV_HELMREPO_CERT__}
EOF
fi

# add cert for accessing docker registry in Azure
if [ ! -z "${__RUNRICENV_DOCKER_CERT__}" ]; then
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

