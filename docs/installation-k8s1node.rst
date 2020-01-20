.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. SPDX-License-Identifier: CC-BY-4.0
.. ===============LICENSE_START=======================================================
.. Copyright (C) 2019-2020 AT&T Intellectual Property
.. ===================================================================================
.. This documentation file is distributed under the Creative Commons Attribution
.. 4.0 International License (the "License"); you may not use this file except in
.. compliance with the License.  You may obtain a copy of the License at
..
.. http://creativecommons.org/licenses/by/4.0
..
.. This file is distributed on an "AS IS" BASIS,
.. WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
.. See the License for the specific language governing permissions and
.. limitations under the License.
.. ===============LICENSE_END=========================================================



Resource Requirements
---------------------

To run Near Realtime RAN Controller in a dev testing setting , the minimum requirement for resources is a VM with 4 vCPUs, 16G RAM, and at least 40G of vDisk space.



Script for Setting Up 1-node Kubernetes Cluster
-----------------------------------------------


The it/dep repo can be used for generating a simple script that can help setting up a one-node Kubernetes cluster for dev and testing purposes.  Related files are under the **ric-infra/00-Kubernetes** directory.

Configurations
--------------

The generation of the script reads in the parameters from the following files:

- etc/env.rc: Normally no change needed for this file.  If where the Kubernetes cluster runs has special requirements, such as running private Docker registry with self-signed certificates, or hostnames that can be only resolved  via private /etc/hosts entries, such parameters are entered into this file.
- etc/infra.rc: This file specifies the versions docker host, Kubernetes, and Kubernetes CNI versions.  If a version is left empty, the installation will use the default version that the OS package management software would install.
- etc/openstack.rc: If the Kubernetes cluster is deployed on Open Stack VMs, this file specifies parameters for accessing the APIs of the Open Stack installation.  This is not supported in Amber release yet.


Generating Set-up Script
------------------------

After the configurations are updated, the following steps will create a script file that can be used for setting up a one-node Kubernetes cluster.

::

  cd bin
  ./gen-cloud-init.sh

A file named **k8s-1node-cloud-init.sh** would now appear under the bin directory.


Setting up Kubernetes Cluster
-----------------------------

The new **k8s-1node-cloud-init.sh** file is now ready for setting up the Kubernetes cluster.

It can be run from a root shell of an existing Ubuntu 16.04 or 18.04 VM.  Running this script will replace any existing installation of Docker host, Kubernetes, and Helm on the VM.

It can also be used as the user-data (a.k.a. cloud-init script) supplicated to Open Stack when launching a new Ubuntu 16.04 or 18.04 VM.

Upon successful execution of the script, when integrated by the kubectl command, the VM should display information similar to below:

::

  # kubectl get pods --all-namespaces
  NAMESPACE     NAME                                   READY   STATUS       RESTARTS  AGE
  kube-system   coredns-5644d7b6d9-4gjp5               1/1     Running      0         103m
  kube-system   coredns-5644d7b6d9-pvsj8               1/1     Running      0         103m
  kube-system   etcd-ljitest                           1/1     Running      0         102m
  kube-system   kube-apiserver-ljitest                 1/1     Running      0         103m
  kube-system   kube-controller-manager-ljitest        1/1     Running      0         102m
  kube-system   kube-flannel-ds-amd64-nvjmq            1/1     Running      0         103m
  kube-system   kube-proxy-867v5                       1/1     Running      0         103m
  kube-system   kube-scheduler-ljitest                 1/1     Running      0         102m
  kube-system   tiller-deploy-68bf6dff8f-6pwvc         1/1     Running      0         102m

