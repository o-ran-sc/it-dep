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

**Loading xApp Helm Charts**

The RIC Platform App Manager deploys RIC applications (a.k.a. xApps) using Helm charts stored in a private local Helm repo.
The Helm local repo is deployed as a sidecar of the App Manager pod, and its APIs are exposed using an ingress controller with TLS enabled.
You can use both HTTP and HTTPS to access it.

Before any xApp can be deployed, its Helm chart must be loaded into this private Helm repo.
The example below shows the command sequences that upload and delete the xApp Helm charts:

#. Load the xApp Helm charts into the Helm repo;
#. Verify the xApp Helm charts;
#. Call App Manager to deploy the xApp;
#. Call App Manager to delete the xApp;
#. Delete the xApp helm chart from the private Helm repo.

In the following example, the <INGRESS_CONTROLLER_IP> is the IP address that the RIC cluster ingress controller is listening to.
If you are using a VM, it is the IP address of the main interface.
If you are using REC clusters, it is the DANM network IP address you assigned in the recipe.
If the commands are executed inside the host machine, you can use "localhost" as the <INGRESS_CONTROLLER_IP>.


.. code:: bash

   # load admin-xapp Helm chart to the Helm repo
   curl -L --data-binary "@admin-xapp-1.0.7.tgz" http://<INGRESS_CONTROLLER_IP>:32080/helmrepo

   # verify the xApp Helm charts
   curl -L http://<INGRESS_CONTROLLER_IP>:32080/helmrepo/index.yaml

   # test App Manager health check API
   curl -v http://<INGRESS_CONTROLLER_IP>:32080/appmgr/ric/v1/health/ready
   # expecting a 200 response

   # list deployed xApps
   curl http://<INGRESS_CONTROLLER_IP>:32080/appmgr/ric/v1/xapps
   # expecting a []

   # deploy xApp, the xApp name has to be the same as the xApp Helm chart name
   curl -X POST http://<INGRESS_CONTROLLER_IP>/appmgr/ric/v1/xapps -d '{"name": "admin-xapp"}'
   # expecting: {"name":"admin-app","status":"deployed","version":"1.0","instances":null}

   # check again deployed xApp
   curl http://<INGRESS_CONTROLLER_IP>:32080/appmgr/ric/v1/xapps
   # expecting a JSON array with an entry for admin-app

   # check pods using kubectl
   kubectl get pods --all-namespaces
   # expecting the admin-xapp pod showing up

   # underlay the xapp
   curl -X DELETE http://<INGRESS_CONTROLLER_IP>:32080/appmgr/ric/v1/xapps/admin-xapp

   # check pods using kubectl
   kubectl get pods --all-namespaces
   # expecting the admin-xapp pod gone or shown as terminating

   # to delete a chart
   curl -L -X DELETE -u helm:helm http://<INGRESS_CONTROLLER_IP>:32080/api/charts/admin-xapp/0.0.5

For more xApp deployment and usage examples, please see the documentation for the it/test repository.
