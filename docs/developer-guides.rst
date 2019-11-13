.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. SPDX-License-Identifier: CC-BY-4.0
.. ===============LICENSE_START=======================================================
.. Copyright (C) 2019 AT&T Intellectual Property      
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

.. contents::
   :depth: 3
   :local:

Developer-Guides
================

Overview
------------------

The Amber release of the it/dep repo provides deployment artifacts for the O-RAN SC
Near Realtime RIC.  The components in the deployment are spread onto two Kubernetes
clusters, one for running the Near Realtime RIC, the other for running auxilary
functions such as the dashboards.  These two clusters are referred to as the RIC and
AUX clusters respectively.

This document describe the deployment artifacts, how theye are organized, and how to
contribute for modifications, additions, and other enhancements to these artifacts.

Deployment Organization
------------------------
To organize the deployments of the compoents, the various O-RAN SC Near Realtime RIC
and auxilary components are organized into three groups: infrastructure, platform,
and auxilary, or ric-infra, ric-platform, and ric-aux respectively. 

The **ric-infra** group is expected to be deployed in each Kubernetes cluster.  It
consists of components such as Kong ingress controller, Helm chart repo, Tiller for
xApp deployment, as well as various credentials.  This group is deployed in both the
RIC and AUX clusters.

The **ric-platform** group is deployed in the RIC cluster.  It consists of all Near
Realtime RIC Platform components, including:

- DBaaS
- E2 Termination
- E2 Manager
- A1 Mediator
- Routing Manager
- Subscription Manager
- xApp manager
- VESPA Manager
- Jaeger Adapter
- Resource Status Manager

The **ric-aux** group is deployed in the AUX cluster.  It consists of components that
facilitate the operation of Near Realtime RIC and receiving inputs from the Near Realtime
RIC.  In Amber release, this group includes the following:

- ONAP VES Collector
- ONAP DMaaP Message Router
- RIC Dashboard

In addition, this group also include ONAP AAF and ONAP Portal.



Directory Structure
-------------------

The directories of the it/dep repo is organized as the following.

::
  
  |-- LICENSES.txt
  |-- README.md
  |-- RECIPE_EXAMPLE
  |-- bin
  |-- ci
  |-- docs
  |-- etc
  |-- ric-aux
  |   |-- 80-Auxiliary-Functions
  |   |-- 85-Ext-Services
  |   `-- README.md
  |-- ric-common
  |   |-- Common-Template
  |   |-- Docker-Credential
  |   |-- Helm-Credential
  |   `-- Initcontainer
  |-- ric-infra
  |   |-- 00-Kubernetes
  |   |-- 15-Chartmuseum
  |   |-- 20-Monitoring
  |   |-- 30-Kong
  |   |-- 40-Credential
  |   |-- 45-Tiller
  |   `-- README.md
  |-- ric-platform
  |   |-- 50-RIC-Platform
  |   |-- 55-Ext-Services
  |   `-- README.md
  `-- tox.ini

The deployment artifacts of these deployment groups are placed under the ric-infra,
ric-platform, and ric-aux directories.  These directories are structured similarly
where underneath each group is a list of numbered sub-groups.  The numbering is
based on the order that how different sub-groups would be deployed within the same
Kubernetes cluster.  For example, the 50-RIC-Platform subgroup should be deployed
before the 55-Ext-Services subgroup.  And all subgroups in the ric-infra group
should be deployed before the sub-groups in the ric-platform group, as indicated
by they sub-group numbers being lower than those of the ric-platform group.

Within each numbered subgroup, there is a **helm** directory and a **bin** directory. 
The bin directory generally contains the install and uninstall script for deploying
all the Helm charts of the subgroup.  The helm directory contains the helm charts
for all the components within the subgroup. 

At the top level, these is also a bin directory, where group level deployment and 
undeployment scripts are located.  For example, the **deploy-ric-platform** script
iterates all the subgroups under the ric-platform group, and calls the install script
of each subgroup to deploy the components in each subgroup.

Recipes
--------
**Recipe** is an important concept for Near Realtime RIC deployment.  Each
deployment group has its own recipe.  Recipe provides a customized specification
for the components of a deployment group for a specific dpeloyment site.  The
RECIPE_EXAMPLE directory contains the example recipes for the three deployment
groups.



Helm Chart Structure
--------------------


Common Chart
^^^^^^^^^^^^

Indiviudal Deployment Tasks
---------------------------


Deploying a 1-node Kubernetes Cluster
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Deploying Near Realtime RIC
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Deploying Near Realtime RIC xApp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



Processes
---------
Contribution to then it/dep repository is open to all community members by following
the standard Git/Gerrit contribution and Gerrit review flows.  

Code change submitted to the it/dep repo of the gerrit.o-ran-sc.org is first reviewed by both an automated verification Jenkins job and human reviewers.


Actions
-------


