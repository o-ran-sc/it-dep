#!/bin/bash

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

# The intention for this script is to stand up a dev testing k8s environment
# that is ready for RIC installation for individual developer/team's API and functional
# testing needs.
# The integration team will maintain the synchronization of software infrastructure
# stack (software, versions and configurations) between this iscript and what is
# provided for the E2E validation testing.  Due to resource and other differences, this
# environment is not intended for any testing related to performance, resilience,
# robustness, etc.

# This script installs docker host, a one-node k8s cluster, and Helm for CoDev.
# This script assumes that it will be executed on an Ubuntu 16.04 VM.
# It is best to be run as the cloud-init script at the VM launch time, or from a
# "sudo -i" shell post-launch on a newly launched VM.
#

set -x

source runric_env.sh

# for RIC R0 we keep 1.13
export KUBEV="1.13.3"
export KUBECNIV="0.6.0"
export DOCKERV="18.06.1"

# for new 1.14 release
#export KUBEVERSION="1.14.0"
#export KUBECNIVERSION="0.7.0"
#export DOCKEFV="18.06.1"

export HELMV="2.12.3"

unset FIRSTBOOT
unset DORESET

while getopts ":r" opt; do
  case ${opt} in
    r )
      DORESET='YES'
      ;;
    \? )
      echo "Usage: $0 [-r]"
      exit
      ;;
  esac
done


if [ ! -e /var/tmp/firstboot4setupk8s ]; then
  echo "First time"
  FIRSTBOOT='YES'
  touch /var/tmp/firstboot4setupk8s

  modprobe -- ip_vs
  modprobe -- ip_vs_rr
  modprobe -- ip_vs_wrr
  modprobe -- ip_vs_sh
  modprobe -- nf_conntrack_ipv4

  # disable swap
  SWAPFILES=$(grep swap /etc/fstab | sed '/^#/ d' |cut -f1 -d' ')
  if [ ! -z $SWAPFILES ]; then
    for SWAPFILE in $SWAPFILES
    do
      echo "disabling swap file $SWAPFILE"
      if [[ $SWAPFILE == UUID* ]]; then
        UUID=$(echo $SWAPFILE | cut -f2 -d'=')
        swapoff -U $UUID
      else
        swapoff $SWAPFILE
      fi
      # edit /etc/fstab file, remove line with /swapfile
      sed -i -e "/$SWAPFILE/d" /etc/fstab
    done
  fi
  # disable swap
  #swapoff /swapfile
  # edit /etc/fstab file, remove line with /swapfile
  #sed -i -e '/swapfile/d' /etc/fstab


  # add rancodev CI tool hostnames
  echo "${__RUNRICENV_GERRIT_IP__} ${__RUNRICENV_GERRIT_HOST__}" >> /etc/hosts
  echo "${__RUNRICENV_DOCKER_IP__} ${__RUNRICENV_DOCKER_HOST__}" >> /etc/hosts
  echo "${__RUNRICENV_HELMREPO_IP__} ${__RUNRICENV_HELMREPO_HOST__}" >> /etc/hosts


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


  KUBEVERSION="${KUBEV}-00"
  CNIVERSION="${KUBECNIV}-00"
  DOCKERVERSION="${DOCKERV}-0ubuntu1.2~16.04.1"
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list

  # install low latency kernel, docker.io, and kubernetes
  apt-get update
  apt-get install -y linux-image-4.15.0-45-lowlatency docker.io=${DOCKERVERSION}
  apt-get install -y kubernetes-cni=${CNIVERSION}
  apt-get install -y --allow-unauthenticated kubeadm=${KUBEVERSION} kubelet=${KUBEVERSION} kubectl=${KUBEVERSION}
  apt-mark hold kubernetes-cni kubelet kubeadm kubectl

  # install Helm
  HELMVERSION=${HELMV}
  cd /root
  mkdir Helm
  cd Helm
  wget https://storage.googleapis.com/kubernetes-helm/helm-v${HELMVERSION}-linux-amd64.tar.gz
  tar -xvf helm-v${HELMVERSION}-linux-amd64.tar.gz
  mv linux-amd64/helm /usr/local/bin/helm


  # add cert for accessing docker registry in Azure
  mkdir -p /etc/docker/certs.d/${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__} 
  cat <<EOF >/etc/docker/ca.crt
-----BEGIN CERTIFICATE-----
MIIEPjCCAyagAwIBAgIJAIwtTKgVAnvrMA0GCSqGSIb3DQEBCwUAMIGzMQswCQYD
VQQGEwJVUzELMAkGA1UECAwCTkoxEzARBgNVBAcMCkJlZG1pbnN0ZXIxDTALBgNV
BAoMBEFUJlQxETAPBgNVBAsMCFJlc2VhcmNoMTswOQYDVQQDDDIqLmRvY2tlci5y
YW5jby1kZXYtdG9vbHMuZWFzdHVzLmNsb3VkYXBwLmF6dXJlLmNvbTEjMCEGCSqG
SIb3DQEJARYUcmljQHJlc2VhcmNoLmF0dC5jb20wHhcNMTkwMTI0MjA0MzIzWhcN
MjQwMTIzMjA0MzIzWjCBszELMAkGA1UEBhMCVVMxCzAJBgNVBAgMAk5KMRMwEQYD
VQQHDApCZWRtaW5zdGVyMQ0wCwYDVQQKDARBVCZUMREwDwYDVQQLDAhSZXNlYXJj
aDE7MDkGA1UEAwwyKi5kb2NrZXIucmFuY28tZGV2LXRvb2xzLmVhc3R1cy5jbG91
ZGFwcC5henVyZS5jb20xIzAhBgkqhkiG9w0BCQEWFHJpY0ByZXNlYXJjaC5hdHQu
Y29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuAW1O52l9/1L+D7x
Qv+782FjiELP9MWO0RCAL2JzV6Ioeo1IvuZl8jvXQVGlowanCdz1HZlMJjGm6Ybv
60dVECRSMZeOxUQ0JCus6thxOhDiiCFT59m+MpdrRgHqwOzw+8B49ZwULv+lTIWt
ETEQkSYTh4No9jCxnyVLKH9DyTbaW/xFK484u5f4bh7mI5uqDJapOCRvJXv8/J0E
eMrkCVmk5qy0ii8I7O0oCNl61YvC5by9GCeuQhloJJc6gOjzKW8nK9JfUW8G34bC
qnUj79EgwgtW/8F5SYAF5LI0USM0xXjyzlnPMbv5mikrbf0EZkZXdUreICUIzY53
HRocCQIDAQABo1MwUTAdBgNVHQ4EFgQUm9NbNhZ3Zp1f50DIN4/4fvWQSNswHwYD
VR0jBBgwFoAUm9NbNhZ3Zp1f50DIN4/4fvWQSNswDwYDVR0TAQH/BAUwAwEB/zAN
BgkqhkiG9w0BAQsFAAOCAQEAkbuqbuMACRmzMXFKoSsMTLk/VRQDlKeubdP4lD2t
Z+2dbhfbfiae9oMly7hPCDacoY0cmlBb2zZ8lgA7kVvuw0xwX8mLGYfOaNG9ENe5
XxFP8MuaCySy1+v5CsNnh/WM3Oznc6MTv/0Nor2DeY0XHQtM5LWrqyKGZaVAKpMW
5nHG8EPIZAOk8vj/ycg3ca3Wv3ne9/8rbrrxDJ3p4L70DOtz/JcQai10Spct4S0Z
7yd4tQL+QSQCvmN7Qm9+i52bY0swYrUAhbNiEX3yJDryKjSCPirePcieGZmBRMxr
7j28jxpa4g32TbWR/ZdxMYEkCVTFViTE23kZdNvahHKfdQ==
-----END CERTIFICATE-----
EOF
  cp /etc/docker/ca.crt /etc/docker/certs.d/${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}/ca.crt
  service docker restart
  systemctl enable docker.service
  docker login -u ${__RUNRICENV_DOCKER_USER__} -p ${__RUNRICENV_DOCKER_PASS__} ${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}
  docker pull ${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}/whoami:0.0.1


  # test access to k8s docker registry
  kubeadm config images pull
else
  echo "Not first boot"

  kubectl get pods --all-namespaces
fi


if [ -n "$DORESET" ]; then
  kubeadm reset
fi

if [ -n ${DORESET+set} ] || [ -n ${FIRSTBOOT+set} ]; then
  # start cluster (make sure CIDR is enabled with the flag)
  kubeadm init --config /root/config.yaml

  # set up kubectl credential and config
  cd /root
  rm -rf .kube
  mkdir -p .kube
  cp -i /etc/kubernetes/admin.conf /root/.kube/config
  chown root:root /root/.kube/config

  # at this point we should be able to use kubectl
  kubectl get pods --all-namespaces
  # you will see the DNS pods stuck in pending state.  They are waiting for some networking to be installed.

  # install flannel
  # kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

  # waiting for all kube-system pods to be in running state
  NUMPODS=0
  while [  $NUMPODS -lt 8 ]; do
    sleep 5
    OUTPUT=$(kubectl get pods --all-namespaces |grep Running)
    NUMPODS=$(echo "$OUTPUT" | wc -l)
    echo "Waiting for $NUMPODS / 8 kube-system pods reaching Running state"
  done

  # if running a single node cluster, need to enable master node to run pods
  kubectl taint nodes --all node-role.kubernetes.io/master-

  cd /root
  # install RBAC for Helm
  kubectl create -f rbac-config.yaml

  rm -rf .helm
  helm init --service-account tiller
  
  
  cat <<EOF >/etc/ca-certificates/update.d/helm.crt
-----BEGIN CERTIFICATE-----
MIIESjCCAzKgAwIBAgIJAIU+AfULkw0PMA0GCSqGSIb3DQEBCwUAMIG5MQswCQYD
VQQGEwJVUzETMBEGA1UECAwKTmV3IEplcnNleTETMBEGA1UEBwwKQmVkbWluc3Rl
cjENMAsGA1UECgwEQVQmVDERMA8GA1UECwwIUmVzZWFyY2gxOTA3BgNVBAMMMCou
aGVsbS5yYW5jby1kZXYtdG9vbHMuZWFzdHVzLmNsb3VkYXBwLmF6dXJlLmNvbTEj
MCEGCSqGSIb3DQEJARYUcmljQHJlc2VhcmNoLmF0dC5jb20wHhcNMTkwMzIxMTU1
MzAwWhcNMjEwMzIwMTU1MzAwWjCBuTELMAkGA1UEBhMCVVMxEzARBgNVBAgMCk5l
dyBKZXJzZXkxEzARBgNVBAcMCkJlZG1pbnN0ZXIxDTALBgNVBAoMBEFUJlQxETAP
BgNVBAsMCFJlc2VhcmNoMTkwNwYDVQQDDDAqLmhlbG0ucmFuY28tZGV2LXRvb2xz
LmVhc3R1cy5jbG91ZGFwcC5henVyZS5jb20xIzAhBgkqhkiG9w0BCQEWFHJpY0By
ZXNlYXJjaC5hdHQuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
tguhSQx5Dk2w+qx2AOcFRz7IZBASEehK1Z4f5jz2KrRylGx6jjedCZASdm1b0ZEB
/ZNrKht1zsWDETa7x0DF+q0Z2blff+T+6+YrJWhNxYHgZiYVi9gTuNDzpn8VVn7f
+cQxcMguHo1JBDIotOLubJ4T3/oXMCPv9kRSLHcNjbEE2yTB3AqXu9dvrDXuUdeU
ot6RzxhKXxRCQXPS2/FDjSV9vr9h1dv5fIkFXihpYaag0XqvXcqgncvcOJ1SsLc3
DK+tyNknqG5SL8y2a7U4F7u+qGO2/3tnCO0ggYwa73hS0pQPY51EpRSckZqlfKEu
Ut0s3wlEFP1VaU0RfU3aIwIDAQABo1MwUTAdBgNVHQ4EFgQUYTpoVXZPXSR/rhjr
pu9PPhL7f9IwHwYDVR0jBBgwFoAUYTpoVXZPXSR/rhjrpu9PPhL7f9IwDwYDVR0T
AQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAUDLbiKVIW6W9qFXLtoyO7S2e
IOUSZ1F70pkfeYUqegsfFZ9njPtPqTzDfJVxYqH2V0vxxoAxXCYCpNyR6vYlYiEL
R+oyxuvauW/yCoiwKBPYa4fD/PBajJnEO1EfIwZvjFLIfw4GjaX59+zDS3Zl0jT/
w3uhPSsJAYXtDKLZ14btA27cM5mW4kmxVD8CRdUW0jr/cN3Hqe9uLSNWCNiDwma7
RnpK7NnOgXHyhZD/nVC0nY7OzbK7VHFJatSOjyuMxgWsFGahwYNxf3AWfPwUai0K
ne/fVFGZ6ifR9QdD0SuKIAEuqSyyP4BsQ92uEweU/gWKsnM6iNVmNFX8UOuU9A==
-----END CERTIFICATE-----
EOF

  # waiting for tiller pod to be in running state
  NUMPODS=0
  while [ $NUMPODS -lt 1 ]; do
    sleep 5
    OUTPUT=$(kubectl get pods --all-namespaces |grep Running)
    NUMPODS=$(echo "$OUTPUT" | grep "tiller-deploy" | wc -l)
    echo "Waiting for $NUMPODS / 1 tiller-deploy pod reaching Running state"
  done

  echo "All up"

  #reboot
fi
