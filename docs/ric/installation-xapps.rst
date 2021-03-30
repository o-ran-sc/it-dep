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

**xApp Onboarding using CLI tool called dms_cli**

xApp onboarder provides a cli tool called dms_cli to fecilitate xApp onboarding service to operators. It consumes the xApp descriptor and optionally additional schema file, and produces xApp helm charts.


Below are the sequence of steps to onboard, install and uninstall the xApp.

Step 1: (OPTIONAL ) Install python3 and its dependent libraries, if not installed.

Step 2: Prepare the xApp descriptor and an optional schema file. xApp descriptor file is a config file that defines the behavior of the xApp. An optional schema file is a JSON schema file that validates the self-defined parameters.

Step 3: Before any xApp can be deployed, its Helm chart must be loaded into this private Helm repository. 

.. code:: bash

   #Create a local helm repository with a port other than 8080 on host
   docker run --rm -u 0 -it -d -p 8090:8080 -e DEBUG=1 -e STORAGE=local -e STORAGE_LOCAL_ROOTDIR=/charts -v $(pwd)/charts:/charts chartmuseum/chartmuseum:latest

Step 4: Set up the environment variables for CLI connection using the same port as used above.

.. code:: bash

   #Set CHART_REPO_URL env variable
   export CHART_REPO_URL=http://0.0.0.0:8090

Step 5: Install dms_cli tool

.. code:: bash

   #Git clone appmgr
   git clone "https://gerrit.o-ran-sc.org/r/ric-plt/appmgr"

   #Change dir to xapp_onboarder
   cd appmgr/xapp_orchestrater/dev/xapp_onboarder

   #If pip3 is not installed, install using the following command
   yum install python3-pip
   
   #In case dms_cli binary is already installed, it can be uninstalled using following command
   pip3 uninstall xapp_onboarder

   #Install xapp_onboarder using following command
   pip3 install ./

Step 6: (OPTIONAL ) If the host user is non-root user, after installing the packages, please assign the permissions to the below filesystems

.. code:: bash

   #Assign relevant permission for non-root user
   sudo chmod 755 /usr/local/bin/dms_cli
   sudo chmod -R 755 /usr/local/lib/python3.6
   sudo chmod -R 755 /usr/local/lib/python3.6

Step 7: Onboard your xApp

.. code:: bash

   # Make sure that you have the xapp descriptor config file and the schema file at your local file system
   dms_cli onboard CONFIG_FILE_PATH SCHEMA_FILE_PATH
   OR
   dms_cli onboard --config_file_path=CONFIG_FILE_PATH --shcema_file_path=SCHEMA_FILE_PATH

   #Example: 
   dms_cli onboard /files/config-file.json /files/schema.json
   OR
   dms_cli onboard --config_file_path=/files/config-file.json --shcema_file_path=/files/schema.json

Step 8: (OPTIONAL ) List the helm charts from help repository.

.. code:: bash

   #List all the helm charts from help repository
   curl -X GET http://localhost:8080/api/charts | jq .

   #List details of specific helm chart from helm repository
   curl -X GET http://localhost:8080/api/charts/<XAPP_CHART_NAME>/<VERSION>

Step 9: (OPTIONAL ) Delete a specific Chart Version from helm repository.

.. code:: bash

   #Delete a specific Chart Version from helm repository
   curl -X DELETE http://localhost:8080/api/charts/<XAPP_CHART_NAME>/<VERSION>

Step 10: (OPTIONAL ) Download the xApp helm charts.

.. code:: bash
   
   dms_cli download_helm_chart XAPP_CHART_NAME VERSION --output_path=OUTPUT_PATH
   OR
   dms_cli download_helm_chart --xapp_chart_name=XAPP_CHART_NAME --version=VERSION --output_path=OUTPUT_PATH
 
   Example: 
   dms_cli download_helm_chart ueec 1.0.0 --output_path=/files/helm_xapp
   OR
   dms_cli download_helm_chart --xapp_chart_name=ueec --version=1.0.0 --output_path=/files/helm_xapp

Step 11: Install the xApp.

.. code:: bash

   dms_cli install XAPP_CHART_NAME VERSION NAMESPACE
   OR
   dms_cli install --xapp_chart_name=XAPP_CHART_NAME --version=VERSION --namespace=NAMESPACE
 
   Example: 
   dms_cli install ueec 1.0.0 ricxapp
   OR
   dms_cli install --xapp_chart_name=ueec --version=1.0.0 --namespace=ricxapp

Step 12: (OPTIONAL ) Install xApp using helm charts by providing the override values.yaml.

.. code:: bash
   
   #Download the default values.yaml
   dms_cli download_values_yaml XAPP_CHART_NAME VERSION --output_path=OUTPUT_PATH
   OR
   dms_cli download_values_yaml --xapp_chart_name=XAPP_CHART_NAME --version=VERSION --output_path=OUTPUT_PATH
 
   Example: 
   dms_cli download_values_yaml traffic-steering 0.6.0 --output-path=/tmp
   OR
   dms_cli download_values_yaml --xapp_chart_name=traffic-steering --version=0.6.0 --output-path=/tmp
 
   #Modify values.yaml and provide it as override file
   dms_cli install XAPP_CHART_NAME VERSION NAMESPACE OVERRIDEFILE
   OR
   dms_cli install --xapp_chart_name=XAPP_CHART_NAME --version=VERSION --namespace=NAMESPACE --overridefile=OVERRIDEFILE
 
   Example: 
   dms_cli install ueec 1.0.0 ricxapp /tmp/values.yaml
   OR
   dms_cli install --xapp_chart_name=ueec --version=1.0.0 --namespace=ricxapp --overridefile=/tmp/values.yaml

Step 13: (OPTIONAL ) Uninstall the xApp.
   
.. code:: bash

   dms_cli uninstall XAPP_CHART_NAME NAMESPACE
   OR
   dms_cli uninstall --xapp_chart_name=XAPP_CHART_NAME --namespace=NAMESPACE
 
   Example: 
   dms_cli uninstall ueec ricxapp
   OR
   dms_cli uninstall --xapp_chart_name=ueec --namespace=ricxapp
   
Step 14: (OPTIONAL) Upgrade the xApp to a new version.

.. code:: bash

   dms_cli upgrade XAPP_CHART_NAME OLD_VERSION NEW_VERSION NAMESPACE
   OR
   dms_cli upgrade --xapp_chart_name=XAPP_CHART_NAME --old_version=OLD_VERSION --new_version=NEW_VERSION --namespace=NAMESPACE
 
   Example: 
   dms_cli upgrade ueec 1.0.0 2.0.0 ricxapp
   OR
   dms_cli upgrade --xapp_chart_name=ueec --old_version=1.0.0 --new_version=2.0.0 --namespace=ricxapp

Step 15: (OPTIONAL) Rollback the xApp to old version. 

.. code:: bash

   dms_cli rollback XAPP_CHART_NAME NEW_VERSION OLD_VERSION NAMESPACE
   OR
   dms_cli rollback --xapp_chart_name=XAPP_CHART_NAME --new_version=NEW_VERSION --old_version=OLD_VERSION --namespace=NAMESPACE
 
   Example: 
   dms_cli rollback ueec 2.0.0 1.0.0 ricxapp
   OR
   dms_cli rollback --xapp_chart_name=ueec --new_version=2.0.0 --old_version=1.0.0 --namespace=ricxapp

Step 16: (OPTIONAL) Check the health of xApp.

.. code:: bash

   dms_cli health_check XAPP_CHART_NAME NAMESPACE
   OR
   dms_cli health_check --xapp_chart_name=XAPP_CHART_NAME --namespace=NAMESPACE
 
   Example: 
   dms_cli health_check ueec ricxapp
   OR
   dms_cli health_check --xapp_chart_name=ueec --namespace=ricxapp
