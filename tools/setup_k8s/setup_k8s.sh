#!/bin/bash

# Capture start time
start_time=$(date +%s)

workspace=$(pwd)

# Define default values
DEFAULT_KUBEVERSION="1.32.3-1.1"
DEFAULT_HELMVERSION="3.14.2"
DEFAULT_POD_CIDR="10.244.0.0/16"

# Parse command-line arguments
IP_ADDR=""
KUBEVERSION="$DEFAULT_KUBEVERSION"
HELMVERSION="$DEFAULT_HELMVERSION"
POD_CIDR="$DEFAULT_POD_CIDR"

while [[ "$#" -gt 0]]; do
    case "$1" in
      --ip-address)
          IP_ADDR="$2"
          shift
          ;;
      --kube-version)
          KUBEVERSION="$2"
          shift
          ;;
      --helm-version)
          KUBEVERSION="$2"
          shift
          ;;
      --pod-cidr)
          KUBEVERSION="$2"
          shift
          ;;    
      *)
          echo "Unknown parameter: $1"
          exit 1
          ;;
    esac
    shift
done

IP_ADDR="$1"
if [ -z "$IP_ADDR" ]; then
  echo "Error: IP address is not set. Please set it before running the script."
  exit 1
fi

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check internet connectivity
check_internet() {
  echo "Checking internet connection..."
  if ping -q -c 1 -W 1 google.com >/dev/null 2>&1; then
    echo "Internet connection is active."
  else
    echo "Error: No internet connection. Please ensure your system has access to the internet."
    exit 1
  fi
}

# Function to check if curl is installed and install if not
check_and_install_curl() {
  echo "Checking if curl is installed..."
  if ! command_exists curl; then
    echo "curl is not installed. Installing now..."
    sudo apt update
    sudo apt install -y curl
    if command_exists curl; then
      echo "curl has been successfully installed."
    else
      echo "Error: Failed to install curl. Please check your internet connection and try again."
      exit 1
    fi
  else
    echo "curl is already installed."
  fi
}

# Function to check for existing Kubernetes cluster and prompt for removal
check_existing_cluster() {
  read -p "This will remove existing cluster if any. Do you want to proceed? (y/N): " remove_cluster
  if [[ "$remove_cluster" != "y" && "$remove_cluster" != "Y" ]]; then
    echo "Kubernetes cluster removal skipped. Exiting script."
    exit 0
  fi
  echo "Removing existing Kubernetes cluster..."
  kubeadm reset -f
  sudo apt-get -y purge kubeadm kubectl kubelet kubernetes-cni kube* containerd
  sudo apt-get -y autoremove
  sudo rm -rf ~/.kube
  apt-get -y autoremove
}

# Function to disable swap
disable_swap() {
  echo "Disabling swap..."
  sudo swapon --show > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    sudo swapoff -a
    sudo rm /swapfile
    sudo sed -i 's/\/swap.img/#\/swap.img/' /etc/fstab
  else
    echo "No swap is currently enabled."
  fi
}

# Function to check Ubuntu version
check_ubuntu_version() {
  os_version=$(lsb_release -rs)
  if [ "$os_version" != "22.04" ] && [ "$os_version" != "24.04" ]; then
    echo "Error: Unsupported Ubuntu version. This script supports 22.04 and 24.04 only."
    exit 1
  fi
}

# Function to handle errors
handle_error() {
  echo "Error occurred at step $1. Exiting..."
  exit 1
}

# Function to check if namespace exists
check_namespace_not_exists() {
    local namespace="$1"
    if kubectl get namespace "$namespace" &> /dev/null; then
        echo "Namespace '$namespace' exists. Skipping steps..."
        return 0  # Namespace exists
    else
        echo "Namespace '$namespace' does not exist."
        return 1  # Namespace does not exist
    fi
}


# Check Ubuntu version
echo "Checking Ubuntu version..."
check_ubuntu_version

# Check internet connection
check_internet

# Check and install curl if not present
check_and_install_curl

# Check for existing Kubernetes cluster and prompt for removal
check_existing_cluster

# Disable swap
disable_swap

# Script for Installing Docker,Kubernetes and Helm

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

# Step x: Edit /etc/sysctl.conf to add fs.inotify.max_user_watches and fs.inotify.max_user_instances. This shoudl be done before containerd installation
echo "==========================================================="
echo " Preping the ENV:  Editing /etc/sysctl.conf..."
echo "==========================================================="

bash -c 'echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf'
bash -c 'echo "fs.inotify.max_user_instances=512" >> /etc/sysctl.conf'
bash -c 'echo "fs.inotify.max_queued_events=16384" >> /etc/sysctl.conf'
bash -c 'echo "vm.max_map_count=262144" >> /etc/sysctl.conf'

# Apply sysctl params without reboot
sudo sysctl --system

# Installing containerd
modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

#V erify that net.ipv4.ip_forward is set to 1 with:
sysctl net.ipv4.ip_forward

echo "****************************************************************************************************************"
echo "						Installing Containerd							"
echo "****************************************************************************************************************"

sysctl --system
apt-get update 
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd

# Helm Installation
echo "****************************************************************************************************************"
echo "						Installing Helm							"
echo "****************************************************************************************************************"
wget https://get.helm.sh/helm-v${HELMVERSION}-linux-amd64.tar.gz
tar -xvf helm-v${HELMVERSION}-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
helm version
rm  helm-v${HELMVERSION}-linux-amd64.tar.gz


# Installing Kubernetes Packages
echo "***************************************************************************************************************"
echo "						Installing Kubernetes						"
echo "***************************************************************************************************************"

rm /etc/apt/keyrings/kubernetes-apt-keyring.gpg
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt update


apt-cache policy kubelet | grep 'Installed: (none)' -A 1000 | grep 'Candidate:' | awk '{print $2}'

# Installing Kubectl, Kubeadm and kubelet

apt install -y kubeadm=${KUBEVERSION} kubelet=${KUBEVERSION} kubectl=${KUBEVERSION}
kubeadm init --apiserver-advertise-address=${IP_ADDR} --pod-network-cidr=${POD_CIDR} --v=5

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node.kubernetes.io/not-ready-

kubectl get pods -A
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

wait_for_pods_running 1 kube-flannel
wait_for_pods_running 7 kube-system

echo "***************************************************************************************************************"

kubectl get pods -A

echo "***************************************************************************************************************"
