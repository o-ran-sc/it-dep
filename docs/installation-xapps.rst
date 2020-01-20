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

Loading xApp Helm Charts
------------------------

The RIC Platform App Manager deploys RIC applications (a.k.a. xApps) using Helm charts stored in a private Helm repo.
In the dev testing deployment described in this documentation, this private Helm repo is the Chart Museum pod that is deployed within the ric infrastructure group into the RIC cluster.

The Helm repo location and credential for access the repo are specified in both the infrastructure and platform recipe files.  

Before any xApp can be deployed, its Helm chart must be loaded into this private Helm repo before the App manager can deploy them. 
The example below show a command sequence that completes:

#. Add the Helm repo at the Helm client running on the RIC cluster host VM (via Kong Ingress Controller);
#. Load the xApp Helm chart into the Helm repo;
#. Update the local cache for the Helm repo and check the Helm chart is loaded;
#. Calling App Manager to deploy the xApp;
#. Calling App Manager to delete the xApp;
#. Delete the xApp helm chart from the private Helm repo.

.. code:: bash

   # add the Chart Museum as repo cm
   helm repo add cm http://10.0.2.100:32080/helm

   # load admin-xapp Helm chart to the Chart Museum
   curl -L -u helm:helm --data-binary "@admin-xapp-1.0.7.tgz" \
      http://10.0.2.100:32080/helm/api/charts

   # check the local cache of repo cm 
   helm repo update cm
   # verify that the Helm chart is loaded and accessible
   helm search cm/
   # the new admin-app chart should show up here.

   # test App Manager health check API
   curl -v http://10.0.2.100:32080/appmgr/ric/v1/health/ready
   # expecting a 200 response

   # list deployed xApps
   curl http://10.0.2.100:32080/appmgr/ric/v1/xapps
   # expecting a []
	
   # deploy xApp
   curl -X POST http://10.0.2.100:32080/appmgr/ric/v1/xapps -d '{"name": "admin-xapp"}'
   # expecting: {"name":"admin-app","status":"deployed","version":"1.0","instances":null}
	
   # check again deployed xApp
   curl http://10.0.2.10:32080/appmgr/ric/v1/xapps
   # expecting a JSON array with an entry for admin-app
	
   # check pods using kubectl
   kubectl get pods --all-namespaces
   # expecting the admin-xapp pod showing up
	
   # underlay the xapp
   curl -X DELETE http://10.0.2.100:32080/appmgr/ric/v1/xapps/admin-xapp

   # check pods using kubectl
   kubectl get pods --all-namespaces
   # expecting the admin-xapp pod gone or shown as terminating

   # to delete a chart
   curl -L -X DELETE -u helm:helm http://10.0.2.100:32080/api/charts/admin-xapp/0.0.5

For more xApp deployment and usage examples, please see the documentation for the it/test repository.
