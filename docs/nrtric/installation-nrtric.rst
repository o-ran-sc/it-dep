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

Edit the recipe files ./RECIPE_EXAMPLE/NONRTRIC/example_recipe.yaml.

- To specify which version of the non-realtime RIC platform components will be deployed, update the platform component container tags in their corresponding section.
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



**Deploying Platform**

After the recipes are edited, the Near Realtime RIC platform is ready to be deployed.

.. code:: bash

  cd dep/bin
  ./deploy-nonrtric ../RECIPE_EXAMPLE/PLATFORM/example_recipe.yaml


**Checking the Deployment Status**

Now check the deployment status after a short wait. Results similar to the
output shown below indicate a complete and successful deployment. Check the
STATUS column from both kubectl outputs to ensure that all are either
"Completed" or "Running", and that none are "Error" or "ImagePullBackOff".

.. code::

  # helm list
  NAME           	REVISION	UPDATED                 	STATUS  	CHART         	APP VERSION	NAMESPACE
  r2-dev-nonrtric	1       	Sat Dec 12 02:55:52 2020	DEPLOYED	nonrtric-2.0.0	           	nonrtric 

  # kubectl get pods -n ricplt
  NAME                                      READY   STATUS     RESTARTS   AGE
  a1-sim-osc-0                              1/1     Running    0          2m8s
  a1-sim-std-0                              1/1     Running    0          2m8s
  a1controller-ff7c8979f-l7skk              1/1     Running    0          2m8s
  controlpanel-859d8c6c6f-hmzrj             1/1     Running    0          2m8s
  db-6b94f965dc-dsch6                       1/1     Running    0          2m8s
  enrichmentservice-587d7d8984-vllst        1/1     Running    0          2m8s
  policymanagementservice-d648f7c9b-54mwc   1/1     Running    0          2m8s
  rappcatalogueservice-7cbbc99b8d-rl2nz     1/1     Running    0          2m8s


**Undeploying Platform**

To undeploy all the containers, perform the following steps in a root shell
within the it-dep repository.

.. code:: bash

  # cd bin
  # ./undeploy-nonrtric

Results similar to below indicate a complete and successful cleanup.

.. code::

  # ./undeploy-ric-platform
  Undeploying NONRTRIC components [controlpanel a1controller a1simulator policymanagementservice enrichmentservice rappcatalogueservice]
  release "r2-dev-nonrtric" deleted
  configmap "nonrtric-recipe" deleted
  namespace "nonrtric" deleted

