### Introduction

This directory contains configurations, templates, and scripts for deploying a Kubernetes cluster for RIC and other AUX functions.

Two methods of deployment are supported:
- Single node Kubernetes cluster deployment: 
  - A cloud init script that installs the docker-kubernetes-helm stack onto a VM launched using cloud Ubuntu 16.04 image.
  - The same script can be run on a newly launched VM using cloud Ubuntu 16.04 image to install the same infrastructure software stack.
- Multi-node, dual-cluster deployment:
  - Using OpenStack Heat Orchestration Template, calling OpenStack stack creation API to create two sets of VMs, one for RIC cluster and the other for AUX cluster.
  - Installing docker-kubernetes-helm stack on each of the VMs.
  - Configuring each set of VMs into a Kubernets cluster.
  - Configure well-known host name resolutions.

### Directory Structure
- bin
 - deploy-stack.sh
 - gen-cloud-init.sh
 - gen-ric-heat-yaml.sh
  - install
 - undeploy-stack.sh
- etc
 - env.rc
 - infra.rc
 - openstack.rc
- heat
 - env
   - aux.env
   - ric.env
 - parts
   - part-1-v6.yaml
   - part-1.yaml
   - part-2-v6.yaml
   - part-2.yaml
   - part-3-v6.yaml
   - part-3.yaml
  - scripts
   - k8s_vm_aux_install.sh
   - k8s_vm_custom_repos.sh
   - k8s_vm_init.sh
   - k8s_vm_init_serv.sh
   - k8s_vm_install.sh


### Configuration
All configurations are under etc directory
- env.rc
 - This file contains configurations for Gerrit, Helm, and Docker registry that will be used for hosting artifacts for the deployment.
- infra.rc
 - This file contains configuratuions infrastructure software stack, e.g. versions of docker, Kubernetes, and Helm software to be installed.
 - Normally there is no need to modify this file.
- openstack.rc 
 - This file contains configuratuions for the local OpenStack instance that will be used for deploying the Heat stacks.


### Deploying 1-node Kubernetes

1. Must complete the local configuration in etc/env.rc file.
2. cd bin
3. ./gen-cloud-init.sh
4. The generated cloud init file is named k8s-1node-cloud-init.sh
5. Use the generate k8s-1node-cloud-init.sh script:
  a. At VM launch time, paste in the contents of the k8s-1node-cloud-init.sh file to the "Customnization script" window of the "Configuration" step, when using Horizon dashboard to launch new VM.
  b. Copy the k8s-1node-cloud-init.sh file to a newly launched cloud image  Ubuntu 16.04 VM.  Run the script in a "sudo -i" shell.
6. After the execution of the script is completed, run "kubectl get pods --all-namespaces" to check.

### Deploying Dual Kubernetes Cluster
1. Must complete the local configuration in etc/env.rc and etc/openstack.rc files.
2. cd bin
3. ./install
4. After the execution is completed, go to WORKDIR_ric and WORKDIR_aux to see the file that contains the IP addresses of the VMs.
5. ssh into the -mst VMs (master nodes) of the clusters, run run "kubectl get pods --all-namespaces" to check.

