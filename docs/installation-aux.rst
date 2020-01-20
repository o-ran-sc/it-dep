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

Edit the recipe files RIC_INFRA_RECIPE_EXAMPLE and RIC_PLATFORM_RECIPE_EXAMPLE.
In particular the following values often need adaptation to local deployments:

#. Docker registry URL
#. Docker registry credential
#. Helm repo credential
#. Component docker container image tags.


Deploying the Aux Group
-----------------------

After the recipes are edited, the AUX group is ready to be deployed.

.. code:: bash

  cd dep/bin
  ./deploy-ric-aux ../RECIPE_EXAMPLE/RIC_INFRA_RECIPE_EXAMPLE
  

Checking the Deployment Status
------------------------------

Now check the deployment status and results similar to the below indicate a complete and successful deployment.

.. code::

  TBD
