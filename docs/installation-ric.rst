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
  # ./deploy-ric-platform ../RECIPE_EXAMPLE/PLATFORM/example_recipe.yaml

Checking the Deployment Status
------------------------------

Now check the deployment status after a short wait. Results similar to the
output shown below indicate a complete and successful deployment. Check the
STATUS column from both kubectl outputs to ensure that all are either 
"Completed" or "Running", and that none are "Error" or "ImagePullBackOff".

.. code::

  # helm list
  NAME             	REVISION	UPDATED                 	STATUS  	CHART               	APP VERSION	NAMESPACE
  r3-a1mediator    	1       	Tue Jan 28 20:11:39 2020	DEPLOYED	a1mediator-3.0.0    	1.0        	ricplt   
  r3-appmgr        	1       	Tue Jan 28 20:10:52 2020	DEPLOYED	appmgr-3.0.0        	1.0        	ricplt   
  r3-dbaas1        	1       	Tue Jan 28 20:11:13 2020	DEPLOYED	dbaas1-3.0.0        	1.0        	ricplt   
  r3-e2mgr         	1       	Tue Jan 28 20:11:23 2020	DEPLOYED	e2mgr-3.0.0         	1.0        	ricplt   
  r3-e2term        	1       	Tue Jan 28 20:11:31 2020	DEPLOYED	e2term-3.0.0        	1.0        	ricplt   
  r3-infrastructure	1       	Tue Jan 28 20:10:39 2020	DEPLOYED	infrastructure-3.0.0	1.0        	ricplt   
  r3-jaegeradapter 	1       	Tue Jan 28 20:12:14 2020	DEPLOYED	jaegeradapter-3.0.0 	1.0        	ricplt   
  r3-rsm           	1       	Tue Jan 28 20:12:04 2020	DEPLOYED	rsm-3.0.0           	1.0        	ricplt   
  r3-rtmgr         	1       	Tue Jan 28 20:11:02 2020	DEPLOYED	rtmgr-3.0.0         	1.0        	ricplt   
  r3-submgr        	1       	Tue Jan 28 20:11:48 2020	DEPLOYED	submgr-3.0.0        	1.0        	ricplt   
  r3-vespamgr      	1       	Tue Jan 28 20:11:56 2020	DEPLOYED	vespamgr-3.0.0      	1.0        	ricplt   

  # kubectl get pods -n ricinfra
  NAME                                        READY   STATUS      RESTARTS   AGE
  deployment-tiller-ricxapp-d4f98ff65-xxpbb   1/1     Running     0          2m46s
  tiller-secret-generator-76b5t               0/1     Completed   0          2m46s

  # kubectl get pods -n ricplt
  NAME                                               READY   STATUS         RESTARTS   AGE
  deployment-ricplt-a1mediator-69f6d68fb4-ndkdv      1/1     Running        0          95s
  deployment-ricplt-appmgr-845d85c989-4z7t5          2/2     Running        0          2m22s
  deployment-ricplt-dbaas-7c44fb4697-6lbqq           1/1     Running        0          2m1s
  deployment-ricplt-e2mgr-569fb7588b-fqfqn           1/1     Running        0          111s
  deployment-ricplt-e2term-alpha-db949d978-nsjds     1/1     Running        0          103s
  deployment-ricplt-jaegeradapter-585b4f8d69-gvmdf   1/1     Running        0          60s
  deployment-ricplt-rsm-755f7c5c85-wdn46             0/1     ErrImagePull   0          69s
  deployment-ricplt-rtmgr-c7cdb5b58-lsqw4            1/1     Running        0          2m12s
  deployment-ricplt-submgr-5b4864dcd7-5k26s          1/1     Running        0          86s
  deployment-ricplt-vespamgr-864f95c9c9-lj74h        1/1     Running        0          78s
  r3-infrastructure-kong-79b6d8b95b-4lg58            2/2     Running        1          2m33s


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

Results similar to below indicate a complete and successful cleanup.

.. code::

  # ./undeploy-ric-platform 
  Undeploying RIC platform components [appmgr rtmgr dbaas1 e2mgr e2term a1mediator submgr vespamgr rsm jaegeradapter infrastructure]
  release "r3-appmgr" deleted
  release "r3-rtmgr" deleted
  release "r3-dbaas1" deleted
  release "r3-e2mgr" deleted
  release "r3-e2term" deleted
  release "r3-a1mediator" deleted
  release "r3-submgr" deleted
  release "r3-vespamgr" deleted
  release "r3-rsm" deleted
  release "r3-jaegeradapter" deleted
  release "r3-infrastructure" deleted
  configmap "ricplt-recipe" deleted
  namespace "ricxapp" deleted
  namespace "ricinfra" deleted
  namespace "ricplt" deleted


Restarting the VM
-----------------

After a reboot of the VM, and a suitable delay for initialization,
all the containers should be running again as shown above.
