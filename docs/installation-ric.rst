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

Run the following commands in a root shell:

.. code:: bash

  git clone http://gerrit.o-ran-sc.org/r/it/dep
  cd RECIPE_EXAMPLE

Edit the recipe files RIC_INFRA_RECIPE_EXAMPLE and RIC_PLATFORM_RECIPE_EXAMPLE.  In particular the following values often need adaptation to local deployments:

#. Docker registry URL;
#. Docker registry credential;
#. Helm repo credential;
#. Component docker container image tags.


Deploying the Infrastructure and Platform Groups
------------------------------------------------

After the recipes are edited, the Near Realtime RIIC is ready to be deployed.

.. code:: bash

  cd dep/bin
  ./deploy-ric-infra ../RECIPE_EXAMPLE/RIC_INFRA_RECIPE_EXAMPLE
  ./deploy-ric-platform ../RECIPE_EXAMPLE/RIC_PLATFORM_RECIPE_EXAMPLE


Checking the Deployment Status
------------------------------

Now check the deployment status and results similar to the below indicate a complete and successful deployment.

.. code::

  # helm list
  NAME                  REVISION UPDATED                   STATUS  	CHART              	APP VERSION	NAMESPACE
  r1-a1mediator         1        Tue Nov 26 00:47:12 2019  DEPLOYED	a1mediator-1.0.0   	1.0             ricplt   
  r1-appmgr             1        Tue Nov 26 00:47:09 2019  DEPLOYED	appmgr-1.1.0       	1.0        	ricplt   
  r1-dbaas1             1        Tue Nov 26 00:47:10 2019  DEPLOYED	dbaas1-1.1.0       	1.0        	ricplt  
  r1-chartmuseum       	1        Tue Nov 26 03:16:42 2019  DEPLOYED	chartmuseum-0.0.1	0.1        	ricinfra  
  r1-e2mgr              1        Tue Nov 26 00:47:10 2019  DEPLOYED	e2mgr-1.1.0        	1.0        	ricplt   
  r1-e2term             1        Tue Nov 26 00:47:11 2019  DEPLOYED	e2term-1.1.0       	1.0        	ricplt   
  r1-extsvcplt          1        Tue Nov 26 00:47:17 2019  DEPLOYED	extsvcplt-0.2.0    	1.0        	ricplt   
  r1-jaegeradapter      1        Tue Nov 26 00:47:16 2019  DEPLOYED	jaegeradapter-0.1.0	1.0        	ricplt   
  r1-kong               1        Tue Nov 26 00:45:36 2019  DEPLOYED	kong-1.0.0         	1.0        	ricinfra 
  r1-ricaux-credential  1        Tue Nov 26 00:45:42 2019  DEPLOYED	credential-1.1.0   	1.0        	ricaux   
  r1-ricinfra-credential 1       Tue Nov 26 00:45:43 2019  DEPLOYED	credential-1.1.0   	1.0        	ricinfra 
  r1-ricplt-credential  1        Tue Nov 26 00:45:42 2019  DEPLOYED	credential-1.1.0   	1.0        	ricplt   
  r1-ricxapp-credential 1        Tue Nov 26 00:45:42 2019  DEPLOYED	credential-1.1.0   	1.0        	ricxapp  
  r1-rsm                1        Tue Nov 26 00:47:15 2019  DEPLOYED	rsm-2.0.6          	1.0        	ricplt   
  r1-rtmgr              1        Tue Nov 26 00:47:09 2019  DEPLOYED	rtmgr-1.1.0        	1.0        	ricplt   
  r1-submgr             1        Tue Nov 26 00:47:13 2019  DEPLOYED	submgr-1.1.0       	1.0        	ricplt   
  r1-vespamgr           1        Tue Nov 26 00:47:14 2019  DEPLOYED	vespamgr-0.0.1     	1.0        	ricplt   
  r1-xapp-tiller        1        Tue Nov 26 00:45:44 2019  DEPLOYED	xapp-tiller-0.1.0  	1.0        	ricinfra 
  # kubectl get pods -n ricplt
  NAME                                              READY   STATUS    RESTARTS   AGE
  deployment-ricplt-a1mediator-5c4df477f9-6zxxx     1/1     Running   0          132m
  deployment-ricplt-appmgr-65bc8b958c-tggg7         1/1     Running   0          132m
  deployment-ricplt-dbaas-74bf584449-k484v          1/1     Running   0          132m
  deployment-ricplt-e2mgr-74cd9865bc-hpn6b          1/1     Running   0          132m
  deployment-ricplt-e2term-cc7b5d99-pkctr           1/1     Running   0          132m
  deployment-ricplt-jaegeradapter-cc49c64dc-vj622   1/1     Running   0          131m
  deployment-ricplt-rsm-599cd4d6c8-4jhft            1/1     Running   0          131m
  deployment-ricplt-rtmgr-85d89868d6-58wvl          1/1     Running   1          132m
  deployment-ricplt-submgr-7cbd697c7f-p9x4x         1/1     Running   0          132m
  deployment-ricplt-vespamgr-7bb4c7585f-9z6qm       1/1     Running   0          132m
  # kubectl get pods -n ricinfra
  NAME                                         READY   STATUS      RESTARTS   AGE
  deployment-ricinfra-chartmuseum-7d97f4b995-gkxsq   1/1     Running     0    133m
  deployment-tiller-ricxapp-65f9cbc8d7-qcr5t   1/1     Running     0          133m
  r1-kong-kong-84695ff65d-9sjwg                2/2     Running     2          133m
  tiller-secret-generator-w6bnd                0/1     Completed   0          133m

