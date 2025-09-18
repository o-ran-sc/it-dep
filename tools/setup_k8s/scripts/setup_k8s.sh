#!/bin/bash
################################################################################
#   Copyright (c) 2025 Broadband Multimedia Wireless Lab, NTUST                #                                #
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

# Capture start time
start_time=$(date +%s)

workspace=$(pwd)

# Define default values
DEFAULT_KUBEVERSION="1.32.8"
DEFAULT_HELMVERSION="3.18.6"
DEFAULT_POD_CIDR="10.244.0.0/16"

# Parse command-line arguments
IP_ADDR=""
KUBEVERSION="$DEFAULT_KUBEVERSION"
HELMVERSION="$DEFAULT_HELMVERSION"
POD_CIDR="$DEFAULT_POD_CIDR"

while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --ip-address)
          IP_ADDR="$2"
          shift 2
          ;;
      --kube-version)
          KUBEVERSION="$2"
          shift 2
          ;;
      --helm-version)
          HELMVERSION="$2"
          shift 2
          ;;
      --pod-cidr)
          POD_CIDR="$2"
          shift 2
          ;;    
      *)
          echo "Unknown parameter: $1"
          exit 1
          ;;
    esac
done

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
    apt update
    apt install -y curl
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
  read -p "This will attempt to remove any existing cluster. Do you want to proceed? (y/N): " remove_cluster
  if [[ "$remove_cluster" != "y" && "$remove_cluster" != "Y" ]]; then
    echo "Kubernetes cluster removal skipped by user. Exiting script."
    exit 0
  fi

  echo "Attempting to remove existing Kubernetes components..."

  # Attempt kubeadm reset if kubeadm is found
  if command_exists kubeadm; then
    echo "Running 'kubeadm reset'..."
    if ! kubeadm reset -f; then
      echo "Warning: 'kubeadm reset' failed or encountered issues. Proceeding with other cleanup steps."
    fi
  else
    echo "Info: 'kubeadm' command not found. Skipping 'kubeadm reset'."
  fi

  # Attempt to purge Kubernetes packages
  echo "Purging Kubernetes packages..."
  if ! apt-get -y purge kubeadm kubectl kubelet kubernetes-cni kube* containerd; then
    echo "Warning: Failed to purge all Kubernetes packages. This might be due to them not being fully installed or other issues."
  fi

  # Attempt autoremove for leftover dependencies
  echo "Running 'apt-get autoremove'..."
  if ! apt-get -y autoremove; then
    echo "Warning: 'apt-get autoremove' failed or encountered issues."
  fi

  # Remove kubeconfig and other user-specific Kubernetes files
  if [ -d "$HOME/.kube" ]; then
    echo "Removing user's .kube directory..."
    if ! rm -rf "$HOME/.kube"; then
      echo "Warning: Failed to remove '$HOME/.kube' directory."
    fi
  else
    echo "Info: '$HOME/.kube' directory not found. Skipping removal."
  fi

  echo "Existing cluster cleanup attempt completed."
}

# Function to disable swap
disable_swap() {
  echo "Disabling swap..."
  swapon --show > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    swapoff -a
    rm /swapfile
    sed -i 's/\/swap.img/#\/swap.img/' /etc/fstab
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
sysctl --system

# Installing containerd
modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sysctl --system

#V erify that net.ipv4.ip_forward is set to 1 with:
sysctl net.ipv4.ip_forward

echo "****************************************************************************************************************"
echo "						Installing Containerd							"
echo "****************************************************************************************************************"

sysctl --system
apt-get update 
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
# increase max_concurrent_downloads to prevent queue waiting time
sed -i '/\[plugins\."io\.containerd\.grpc\.v1\.cri"\]/,/^$/{/max_concurrent_downloads/s/=.*/= 20/}' /etc/containerd/config.toml
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
# Derive repo channel (major.minor) for Kubernetes apt source after parsing options
KUBE_REPO_CHANNEL="$(echo "${KUBEVERSION#v}" | cut -d. -f1,2)"
KUBE_REPO_URL="https://pkgs.k8s.io/core:/stable:/v${KUBE_REPO_CHANNEL}/deb"

rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
mkdir -p /etc/apt/keyrings
curl -fsSL "${KUBE_REPO_URL}/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] ${KUBE_REPO_URL}/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt update

# Installing Kubectl, Kubeadm and kubelet
VERSION=$(apt-cache madison kubeadm | awk -v ver="${KUBEVERSION#v}" '$3 == ver"-1.1" {print $3; exit}') # convert actual version to available debian versioning
apt install -y kubeadm=${VERSION} kubelet=${VERSION} kubectl=${VERSION}
kubeadm init --apiserver-advertise-address=${IP_ADDR} --pod-network-cidr=${POD_CIDR} --v=5

# For CICD purpose
TARGET_USER="${SUDO_USER}"

# Get the home directory of the target user
TARGET_HOME=$(getent passwd "${TARGET_USER}" | cut -d: -f6)

if [[ -z "${TARGET_HOME}" ]]; then
    echo "Error: Home directory for user ${TARGET_USER} could not be found."
    exit 1
fi

echo "Setting up kubectl for user: ${TARGET_USER} in home directory: ${TARGET_HOME}"

# Create the .kube directory in the correct user's home
mkdir -p "${TARGET_HOME}/.kube"

# Copy the admin.conf file
cp -i /etc/kubernetes/admin.conf "${TARGET_HOME}/.kube/config"

# Change the ownership to the correct user.
chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.kube"

# Set the correct permissions for the file.
chmod 600 "${TARGET_HOME}/.kube/config"

export KUBECONFIG="${TARGET_HOME}/.kube/config"

# Release taint
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node.kubernetes.io/not-ready-

kubectl get pods -A

echo "***************************************************************************************************************"
echo "						Installing CNI						"
echo "***************************************************************************************************************"

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.1/manifests/calico.yaml

wait_for_pods_running 7 kube-system

echo "***************************************************************************************************************"

kubectl get pods -A

echo "***************************************************************************************************************"
