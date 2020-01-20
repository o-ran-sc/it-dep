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


Getting and Preparing Deployment Scripts
----------------------------------------

Clone the it/dep git repository that has deployment scripts and support files on the target VM. 
(You might have already done this in a previous step.)

::

  % git clone https://gerrit.o-ran-sc.org/r/it/dep

Check out the appropriate branch of the repository with the release you want to deploy.
For example:

::

  % git checkout Amber

In the RECIPE_EXAMPLE directory, edit the recipe files RIC_INFRA_RECIPE_EXAMPLE and
RIC_PLATFORM_RECIPE_EXAMPLE. In particular the following values often need adaptation
to local deployments:

#. Docker registry URL (property "repository"). This is the default source for
   container images. For example,
   nexus3.o-ran-sc.org:10004/o-ran-sc is the staging registry and has freshly built images;
   nexus3.o-ran-sc.org:10002/o-ran-sc is the release registry and has stable images.
#. Docker registry credential. This is a name of a Kubernetes credential. Some registries
   allow anonymous read access, including nexus3.o-ran-sc.org.
#. Helm repo and credential. The xApp Manager deploys xApps from charts in this repo.
   No changes are required here for basic dev testing of platform components.
#. Component docker container image repository override and tag.  The recipes specify
   the docker image to use in terms of name and tag.  These entries also allow override
   of the default docker registry URL (see above); for example, the default might be the
   releases registry and then a component under test is deployed from the staging registry.


Deploying the Infrastructure and Platform Groups
------------------------------------------------

After the recipes are edited, the Near Realtime RIC is ready to be deployed.
Perform the following steps in a root shell.

.. code:: bash

  % sudo -i
  # cd dep/bin
  # ./deploy-ric-infra ../RECIPE_EXAMPLE/RIC_INFRA_RECIPE_EXAMPLE
  # ./deploy-ric-platform ../RECIPE_EXAMPLE/RIC_PLATFORM_RECIPE_EXAMPLE


Checking the Deployment Status
------------------------------

Now check the deployment status after a short wait. Results similar to the
output shown below indicate a complete and successful deployment. Check the
STATUS column from both kubectl outputs to ensure that all are either 
"Completed" or "Running", and that none are "Error" or "ImagePullBackOff".

.. code::

  # helm list
  NAME                   REVISION UPDATED                   STATUS  	CHART              	APP VERSION	NAMESPACE
  r1-a1mediator          1        Tue Nov 26 00:47:12 2019  DEPLOYED	a1mediator-2.0.0   	1.0         ricplt
  r1-appmgr              1        Tue Nov 26 00:47:09 2019  DEPLOYED	appmgr-1.1.0       	1.0        	ricplt
  r1-chartmuseum       	 1        Tue Nov 26 03:16:42 2019  DEPLOYED	chartmuseum-0.0.1   0.1        	ricinfra
  r1-dbaas1              1        Tue Nov 26 00:47:10 2019  DEPLOYED	dbaas1-1.1.0       	1.0        	ricplt
  r1-e2mgr               1        Tue Nov 26 00:47:10 2019  DEPLOYED	e2mgr-1.1.0        	1.0        	ricplt
  r1-e2term              1        Tue Nov 26 00:47:11 2019  DEPLOYED	e2term-1.1.0       	1.0        	ricplt
  r1-extsvcplt           1        Tue Nov 26 00:47:17 2019  DEPLOYED	extsvcplt-0.2.0    	1.0        	ricplt
  r1-jaegeradapter       1        Tue Nov 26 00:47:16 2019  DEPLOYED	jaegeradapter-0.1.0	1.0        	ricplt
  r1-kong                1        Tue Nov 26 00:45:36 2019  DEPLOYED	kong-1.0.0         	1.0        	ricinfra
  r1-ricaux-credential   1        Tue Nov 26 00:45:42 2019  DEPLOYED	credential-1.1.0   	1.0        	ricaux
  r1-ricinfra-credential 1        Tue Nov 26 00:45:43 2019  DEPLOYED	credential-1.1.0   	1.0        	ricinfra
  r1-ricplt-credential   1        Tue Nov 26 00:45:42 2019  DEPLOYED	credential-1.1.0   	1.0        	ricplt
  r1-ricxapp-credential  1        Tue Nov 26 00:45:42 2019  DEPLOYED	credential-1.1.0   	1.0        	ricxapp
  r1-rsm                 1        Tue Nov 26 00:47:15 2019  DEPLOYED	rsm-2.0.6          	1.0        	ricplt
  r1-rtmgr               1        Tue Nov 26 00:47:09 2019  DEPLOYED	rtmgr-1.1.0        	1.0        	ricplt
  r1-submgr              1        Tue Nov 26 00:47:13 2019  DEPLOYED	submgr-1.1.0       	1.0        	ricplt
  r1-vespamgr            1        Tue Nov 26 00:47:14 2019  DEPLOYED	vespamgr-0.0.1     	1.0        	ricplt
  r1-xapp-tiller         1        Tue Nov 26 00:45:44 2019  DEPLOYED	xapp-tiller-0.1.0  	1.0        	ricinfra

  # kubectl get pods -n ricinfra
  NAME                                              READY   STATUS     RESTARTS   AGE
  deployment-ricinfra-chartmuseum-7d97f4b995-gkxsq  1/1     Running    0          133m
  deployment-tiller-ricxapp-65f9cbc8d7-qcr5t        1/1     Running    0          133m
  job-ricinfra-chartmuseum-save-certs-5ntnk         0/1     Completed  0          133m
  r1-kong-kong-84695ff65d-9sjwg                     2/2     Running    2          133m
  tiller-secret-generator-w6bnd                     0/1     Completed  0          133m

  # kubectl get pods -n ricplt
  NAME                                              READY   STATUS     RESTARTS   AGE
  deployment-ricplt-a1mediator-5c4df477f9-6zxxx     1/1     Running    0          132m
  deployment-ricplt-appmgr-65bc8b958c-tggg7         1/1     Running    0          132m
  deployment-ricplt-dbaas-74bf584449-k484v          1/1     Running    0          132m
  deployment-ricplt-e2mgr-74cd9865bc-hpn6b          1/1     Running    0          132m
  deployment-ricplt-e2term-cc7b5d99-pkctr           1/1     Running    0          132m
  deployment-ricplt-jaegeradapter-cc49c64dc-vj622   1/1     Running    0          131m
  deployment-ricplt-rsm-599cd4d6c8-4jhft            1/1     Running    0          131m
  deployment-ricplt-rtmgr-85d89868d6-58wvl          1/1     Running    1          132m
  deployment-ricplt-submgr-7cbd697c7f-p9x4x         1/1     Running    0          132m
  deployment-ricplt-vespamgr-7bb4c7585f-9z6qm       1/1     Running    0          132m


Checking Container Health
-------------------------

Check the health of the application manager platform component by querying it
via the ingress controller using the following command.

.. code:: bash

  % curl -v http://localhost:32080/appmgr/ric/v1/health/ready

The output should look as follows.

.. code::

  *   Trying 10.0.2.100...
  * TCP_NODELAY set
  * Connected to 10.0.2.100 (10.0.2.100) port 32080 (#0)
  > GET /appmgr/ric/v1/health/ready HTTP/1.1
  > Host: 10.0.2.100:32080
  > User-Agent: curl/7.58.0
  > Accept: */*
  > 
  < HTTP/1.1 200 OK
  < Content-Type: application/json
  < Content-Length: 0
  < Connection: keep-alive
  < Date: Wed, 22 Jan 2020 20:55:39 GMT
  < X-Kong-Upstream-Latency: 0
  < X-Kong-Proxy-Latency: 2
  < Via: kong/1.3.1
  < 
  * Connection #0 to host 10.0.2.100 left intact


Undeploying the Infrastructure and Platform Groups
--------------------------------------------------

To undeploy all the containers, perform the following steps in a root shell
within the it-dep repository.

.. code:: bash

  # cd bin
  # ./undeploy-ric-platform
  # ./undeploy-ric-infra

Results similar to below indicate a complete and successful cleanup.

.. code::

  # ./undeploy-ric-platform 
  Undeploying RIC platform components [appmgr rtmgr dbaas1 e2mgr e2term a1mediator submgr vespamgr rsm jaegeradapter]
  release "r1-appmgr" deleted
  release "r1-rtmgr" deleted
  release "r1-dbaas1" deleted
  release "r1-e2mgr" deleted
  release "r1-e2term" deleted
  release "r1-a1mediator" deleted
  release "r1-submgr" deleted
  release "r1-vespamgr" deleted
  release "r1-rsm" deleted
  release "r1-jaegeradapter" deleted
  Undeploying RIC platform components [extsvcplt]
  release "r1-extsvcplt" deleted
  
  # ./undeploy-ric-infra
  Please reset your kubernetes cluster manually.
  Undeploying RIC infra components [chartmuseum]
  release "r1-chartmuseum" deleted
  Undeploying RIC infra components [elfkp]
  Undeploying RIC infra components [kong]
  release "r1-kong" deleted
  Undeploying RIC infra components [credential]
  release "r1-ricaux-credential" deleted
  release "r1-ricinfra-credential" deleted
  release "r1-ricplt-credential" deleted
  release "r1-ricxapp-credential" deleted
  Undeploying RIC infra components [xapp-tiller]
  release "r1-xapp-tiller" deleted


Restarting the VM
-----------------

After a reboot of the VM, and a suitable delay for initialization,
all the containers should be running again as shown above.
