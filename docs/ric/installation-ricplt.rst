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


**Getting and Preparing Deployment Scripts**

Clone the it/dep git repository that has deployment scripts and support files on the target VM.
(You might have already done this in a previous step.)

::

  % git clone https://gerrit.o-ran-sc.org/r/it/dep

Check out the appropriate branch of the repository with the release you want to deploy.
For example:

.. code:: bash

  git clone https://gerrit.o-ran-sc.org/r/it/dep
  cd dep
  git submodule update --init --recursive --remote

**Modify the deployment recipe**

Edit the recipe files ./RECIPE_EXAMPLE/PLATFORM/example_recipe.yaml.

- Specify the IP addresses used by the RIC and AUX cluster ingress controller (e.g., the main interface IP) in the following section. If you do not plan to set up an AUX cluster, you can put down any private IPs (e.g., 10.0.2.1 and 10.0.2.2).

.. code:: bash

  extsvcplt:
    ricip: ""
    auxip: ""

- Deployment scripts support both helm v2 and v3. The deployment script will determine the helm version installed in cluster during the deployment.
- To specify which version of the RIC platform components will be deployed, update the RIC platform component container tags in their corresponding section.
- You can specify which docker registry will be used for each component. If the docker registry requires login credential, you can add the credential in the following section. Please note that the installation suite has already included credentials for O-RAN Linux Foundation docker registries. Please do not create duplicate entries.

.. code:: bash

  docker-credential:
    enabled: true
    credential:
      SOME_KEY_NAME:
        registry: ""
        credential:
          user: ""
          password: ""
          email: ""

For more advanced recipe configuration options, please refer to the recipe configuration guideline.


**Deploying the Infrastructure and Platform Groups**

After the recipes are edited, the Near Realtime RIC platform is ready to be deployed.

.. code:: bash

  cd dep/bin
  ./deploy-ric-platform ../RECIPE_EXAMPLE/PLATFORM/example_recipe.yaml


**Checking the Deployment Status**

Now check the deployment status after a short wait. Results similar to the
output shown below indicate a complete and successful deployment. Check the
STATUS column from both kubectl outputs to ensure that all are either
"Completed" or "Running", and that none are "Error" or "ImagePullBackOff".

.. code::

  # helm list
  NAME                  REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
  r3-a1mediator         1               Thu Jan 23 14:29:12 2020        DEPLOYED        a1mediator-3.0.0        1.0             ricplt
  r3-appmgr             1               Thu Jan 23 14:28:14 2020        DEPLOYED        appmgr-3.0.0            1.0             ricplt
  r3-dbaas1             1               Thu Jan 23 14:28:40 2020        DEPLOYED        dbaas1-3.0.0            1.0             ricplt
  r3-e2mgr              1               Thu Jan 23 14:28:52 2020        DEPLOYED        e2mgr-3.0.0             1.0             ricplt
  r3-e2term             1               Thu Jan 23 14:29:04 2020        DEPLOYED        e2term-3.0.0            1.0             ricplt
  r3-infrastructure     1               Thu Jan 23 14:28:02 2020        DEPLOYED        infrastructure-3.0.0    1.0             ricplt
  r3-jaegeradapter      1               Thu Jan 23 14:29:47 2020        DEPLOYED        jaegeradapter-3.0.0     1.0             ricplt
  r3-rsm                1               Thu Jan 23 14:29:39 2020        DEPLOYED        rsm-3.0.0               1.0             ricplt
  r3-rtmgr              1               Thu Jan 23 14:28:27 2020        DEPLOYED        rtmgr-3.0.0             1.0             ricplt
  r3-submgr             1               Thu Jan 23 14:29:23 2020        DEPLOYED        submgr-3.0.0            1.0             ricplt
  r3-vespamgr           1               Thu Jan 23 14:29:31 2020        DEPLOYED        vespamgr-3.0.0          1.0             ricplt

  # kubectl get pods -n ricplt
  NAME                                               READY   STATUS             RESTARTS   AGE
  deployment-ricplt-a1mediator-69f6d68fb4-7trcl      1/1     Running            0          159m
  deployment-ricplt-appmgr-845d85c989-qxd98          2/2     Running            0          160m
  deployment-ricplt-dbaas-7c44fb4697-flplq           1/1     Running            0          159m
  deployment-ricplt-e2mgr-569fb7588b-wrxrd           1/1     Running            0          159m
  deployment-ricplt-e2term-alpha-db949d978-rnd2r     1/1     Running            0          159m
  deployment-ricplt-jaegeradapter-585b4f8d69-tmx7c   1/1     Running            0          158m
  deployment-ricplt-rsm-755f7c5c85-j7fgf             1/1     Running            0          158m
  deployment-ricplt-rtmgr-c7cdb5b58-2tk4z            1/1     Running            0          160m
  deployment-ricplt-submgr-5b4864dcd7-zwknw          1/1     Running            0          159m
  deployment-ricplt-vespamgr-864f95c9c9-5wth4        1/1     Running            0          158m
  r3-infrastructure-kong-68f5fd46dd-lpwvd            2/2     Running            3          160m

  # kubectl get pods -n ricinfra
  NAME                                        READY   STATUS      RESTARTS   AGE
  deployment-tiller-ricxapp-d4f98ff65-9q6nb   1/1     Running     0          163m
  tiller-secret-generator-plpbf               0/1     Completed   0          163m

**Checking Container Health**

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


**Undeploying the Infrastructure and Platform Groups**

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


**Restarting the VM**

After a reboot of the VM, and a suitable delay for initialization,
all the containers should be running again as shown above.
