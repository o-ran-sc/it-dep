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

===================
Installation Guides
===================

This document describes how to install the RIC components deployed by scripts and Helm charts
under the it/dep repository, including the dependencies and required system resources.

.. contents::
   :depth: 3
   :local:

Version history
===============

+--------------------+--------------------+--------------------+--------------------+
| **Date**           | **Ver.**           | **Author**         | **Comment**        |
|                    |                    |                    |                    |
+--------------------+--------------------+--------------------+--------------------+
| 2019-11-25         | 0.1.0              |Lusheng Ji          | First draft        |
|                    |                    |                    |                    |
+--------------------+--------------------+--------------------+--------------------+


Overview
========

The installation of Amber Near Realtime RAN Intelligent Controller is spread onto two separate
Kubernetes clusters.  The first cluster is used for deploying the Near Realtime RIC (platform and
applications), and the other is for deploying other auxiliary functions.  They are referred to as
RIC cluster and AUX cluster respectively.

The following diagram depicts the installation architecture.

.. image:: images/nrtric-amber.png
   :width: 600

Within the RIC cluster, Kubernetes resources are deployed using three name spaces: ricinfra, ricplt,
and ricxapp.  Similarly, within the AUX cluster, Kubernetes resources are deployed using two name spaces:
ricinfra, and ricaux.

For each cluster, there is a Kong ingress controller that proxies incoming API calls into the cluster.
With Kong, service APIs provided by Kubernetes resources can be accessed at the cluster node IP and
port via a URL path.  For cross-cluster communication, in addition to Kong, each Kubernetes namespace
has a special Kubernetes service defined with an endpoint pointing to the other cluster's Kong. This
way any pod can access services exposed at the other cluster via the internal service hostname and port of
this special service.  The figure below illustrates the details of how Kong and external services work
together to realize cross-cluster communication.

.. image:: images/kong-extservice.png
   :width: 600


VirtualBox VMs as Installation Hosts
====================================

The deployment of Amber Near Realtime RIC can be done on a wide range of hosts, including
bare metal servers, OpenStack VMs, and VirtualBox VMs.  This section provides detailed instructions
for setting up Oracle VirtualBox VMs to be used as installation hosts.

.. include:: ./installation-virtualbox.rst


One-Node Kubernetes Cluster
===========================

This section describes how to set up a one-node Kubernetes cluster onto a VM installation host.

.. include:: ./installation-k8s1node.rst


Installing Near Realtime RIC in RIC Cluster
===========================================

After the Kubernetes cluster is installed, the next step is to install the (Near Realtime) RIC Platform.

.. include:: ./installation-ric.rst


Installing Auxiliary Functions in AUX Cluster
=============================================

.. include:: ./installation-aux.rst


Installing RIC Applications
===========================

.. include:: ./installation-xapps.rst

