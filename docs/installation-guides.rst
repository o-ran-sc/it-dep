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

========
Abstract
========

This document describes how to install the components deployed by scripts and Helm charts
under the it/dep repository, it's dependencies and required system resources.

.. contents::
   :depth: 3
   :local:

Version history
---------------------

+--------------------+--------------------+--------------------+--------------------+
| **Date**           | **Ver.**           | **Author**         | **Comment**        |
|                    |                    |                    |                    |
+--------------------+--------------------+--------------------+--------------------+
| 2019-11-25         | 0.1.0              |Lusheng Ji          | First draft        |
|                    |                    |                    |                    |
+--------------------+--------------------+--------------------+--------------------+


Introduction
============

.. image:: images/nrtric-amber.png
   :width: 600
.. image:: images/kong-extservice.png
   :width: 600

.. include:: ./installation-virtualbox.rst

.. include:: ./installation-k8s1node.rst

.. include:: ./installation-ric.rst 

.. include:: ./installation-aux.rst

.. include:: ./installation-xapps.rst




