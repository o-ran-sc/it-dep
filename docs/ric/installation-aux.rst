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

**Resource Requirements**

To run the RIC-AUX cluster in a dev testing setting, the minimum requirement
for resources is a VM with 4 vCPUs, 16G RAM and at least 40G of disk space.


**Getting and Preparing Deployment Scripts**

Run the following commands in a root shell:

.. code:: bash

  git clone https://gerrit.o-ran-sc.org/r/it/dep
  cd dep
  git submodule update --init --recursive --remote


**Modify the deployment recipe**

Edit the recipe file ./RECIPE_EXAMPLE/AUX/example_recipe.yaml.

- Specify the IP addresses used by the RIC and AUX cluster ingress controller (e.g., the main interface IP) in the following section.
  If you are only testing the AUX cluster, you can put down any private IPs (e.g., 10.0.2.1 and 10.0.2.2).

.. code:: bash

  extsvcplt:
    ricip: ""
    auxip: ""

- To specify which version of the RIC platform components will be deployed, update the RIC platform component container tags in their corresponding section.
- You can specify which docker registry will be used for each component. If the docker registry requires login credential, you can add the credential in the following section.
  Note that the installation script has already included credentials for O-RAN Linux Foundation docker registries. Please do not create duplicate entries.

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

For more advanced recipe configuration options, refer to the recipe configuration guideline.


**Deploying the Aux Group**

After the recipes are edited, the AUX group is ready to be deployed.

.. code:: bash

  cd dep/bin
  ./deploy-ric-aux ../RECIPE_EXAMPLE/AUX/example_recipe.yaml


**Checking the Deployment Status**

Now check the deployment status and results similar to the below indicate a complete and successful deployment.

.. code::

  # helm list
  NAME                  REVISION        UPDATED                         STATUS          CHART                   APP VERSION     NAMESPACE
  r3-aaf                1               Mon Jan 27 13:24:59 2020        DEPLOYED        aaf-5.0.0                               onap
  r3-dashboard          1               Mon Jan 27 13:22:52 2020        DEPLOYED        dashboard-1.2.2         1.0             ricaux
  r3-infrastructure     1               Mon Jan 27 13:22:44 2020        DEPLOYED        infrastructure-3.0.0    1.0             ricaux
  r3-mc-stack           1               Mon Jan 27 13:23:37 2020        DEPLOYED        mc-stack-0.0.1          1               ricaux
  r3-message-router     1               Mon Jan 27 13:23:09 2020        DEPLOYED        message-router-1.1.0                    ricaux
  r3-mrsub              1               Mon Jan 27 13:23:24 2020        DEPLOYED        mrsub-0.1.0             1.0             ricaux
  r3-portal             1               Mon Jan 27 13:24:12 2020        DEPLOYED        portal-5.0.0                            ricaux
  r3-ves                1               Mon Jan 27 13:23:01 2020        DEPLOYED        ves-1.1.1               1.0             ricaux

  # kubectl get pods -n ricaux
  NAME                                           READY   STATUS     RESTARTS   AGE
  deployment-ricaux-dashboard-f78d7b556-m5nbw    1/1     Running    0          6m30s
  deployment-ricaux-ves-69db8c797-v9457          1/1     Running    0          6m24s
  elasticsearch-master-0                         1/1     Running    0          5m36s
  r3-infrastructure-kong-7697bccc78-nsln7        2/2     Running    3          6m40s
  r3-mc-stack-kibana-78f648bdc8-nfw48            1/1     Running    0          5m37s
  r3-mc-stack-logstash-0                         1/1     Running    0          5m36s
  r3-message-router-message-router-0             1/1     Running    3          6m11s
  r3-message-router-message-router-kafka-0       1/1     Running    1          6m11s
  r3-message-router-message-router-kafka-1       1/1     Running    2          6m11s
  r3-message-router-message-router-kafka-2       1/1     Running    1          6m11s
  r3-message-router-message-router-zookeeper-0   1/1     Running    0          6m11s
  r3-message-router-message-router-zookeeper-1   1/1     Running    0          6m11s
  r3-message-router-message-router-zookeeper-2   1/1     Running    0          6m11s
  r3-mrsub-5c94f5b8dd-wxcw5                      1/1     Running    0          5m58s
  r3-portal-portal-app-8445f7f457-dj4z8          2/2     Running    0          4m53s
  r3-portal-portal-cassandra-79cf998f69-xhpqg    1/1     Running    0          4m53s
  r3-portal-portal-db-755b7dc667-kjg5p           1/1     Running    0          4m53s
  r3-portal-portal-db-config-bfjnc               2/2     Running    0          4m53s
  r3-portal-portal-zookeeper-5f8f77cfcc-t6z7w    1/1     Running    0          4m53s
