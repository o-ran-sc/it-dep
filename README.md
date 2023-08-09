<!---

Copyright (c) 2019 AT&T Intellectual Property.
Modifications Copyright (C) 2023 Nordix.

Licensed under the Creative Commons License, Attribution 4.0 Intl.
(the"Documentation License"); you may not use this documentation
except incompliance with the Documentation License. You may obtain
a copy of the Documentation License at 

    https://creativecommons.org/licenses/by/4.0/

Unless required by applicable law or agreed to in writing, 
documentation distributed under the Documentation License is
distributed on an "AS IS"BASIS, WITHOUT WARRANTIES OR CONDITIONS
OF ANY KIND, either express or implied. See the Documentation
License for the specific language governing permissions and
limitations under the Documentation License.

-->

This is a comment, it will not be included)
[comment]: <> (in  the output file unless you use it in)
[comment]: <> (a reference style link.)


# RIC Integration
  
This repo contains RAN Intelligent Controller (RIC) deployments related files.


### Overview

The RIC deployment scripts are designed to deploy RIC components using helm charts. A deployment recipe yaml file that
contains parameter key:value pairs can be provided as a parameter for any deployment script in this repository. The
deployment recipe is acting as the helm override values.yaml file. The default parameters are set up to deploy a 
RIC instance using Linux Foundation repositories in a self-contained environment. 


### Directory Structure
.
├── bin
├── ci
├── docs
├── LICENSES.txt	License information
├── README.md           This file
├── RECIPE_EXAMPLE	Directory that contains deploy recipe examples
├── ric-aux		Deployment scripts, charts and configuration files for RIC auxilary functions
├── ric-common		Deployment scripts, charts and configuration files for RIC common template
├── ric-dep	        Deployment scripts, charts and configuration files for RIC platform components
└── tools		Deployment scripts, charts and configuration files for K8S deployment

The deployment scripts are designed to be modularized. Each submodule is managed independently in other Git repo and they can be deployed and undeployed separately. These submodules are coupled together throught the ric-common template which provides common references to naming convention, settings, and configurations. Currently ric-dep is the submodule for RIC platform deployment, and ric-aux is the submodule for the auxilary functions deployment (currently ric-aux is still managed by it/dep repo). In the future, more submodules can be added without changing the structure.

The one-click RIC deployment/undeployment scripts in the ./bin directory will call the deployment/undeployment scripts in the corresponding submodule directory respectively.
In each of the submodule directories, ./bin contains the binary and script files and ./helm contains the helm charts. For the rest of the non-submodule directories please refer to the README.md files in them for more details. 


### Prerequisites

To deploy RIC, you need to have a cluster that runs kubernetes (version > v.1.16.0) and helm (version v2.14.3).
Tools to install a K8S environment in an openstack cloud can be found in ./tools/k8s.
Please refer to the README.md file for more details 

### To deploy RIC Platform
Choose a deployment recipe (e.g, ./RECIPE_EXAMPLE/PLATFORM/amber_example_recipe.yaml)
Make a copy of the recipe and edit the key:value pairs in it according to your needs
Make sure that you have the correct docker image registry, name, and tag spcified for all the components.
Set the values of extsvcaux/ricip and extsvcaux/auxip to be the external IP addresses of VM hosting RIC cluster and VM hosting AUX cluster, respectively.
Then run the following to deploy:
```sh
$ . ./deploy-ric-platform -f <PATH_TO_YOUR_MODIFIED_RECIPE>
```
Run the following to undeploy:
```sh
$ . ./undeploy-ric-platform 
```

### To deploy RIC Auxiliary functions
Choose a deployment recipe (e.g, ./RECIPE_EXAMPLE/AUX/amber_example_recipe.yaml)
Make a copy of the recipe and edit the key:value pairs in it according to your needs
Set the values of extsvcaux/ricip and extsvcaux/auxip to be the external IP addresses of VM hosting RIC cluster and VM hosting AUX cluster, respectively.
```sh
$ . ./deploy-ric-aux -f <PATH_TO_YOUR_MODIFIED_RECIPE>
```
Run the following to undeploy:
```sh
$ . ./undeploy-ric-aux 
```

### NOTE: To Deploy RANPM
RANPM helm charts are integrated as a submodule in this repository. To deploy RANPM function set installRanpm: true in the RECEPIE_EXAMPLE file as below:

nonrtric:
  installPms: true
  installA1controller: true
  installA1simulator: true
  installControlpanel: true
  installInformationservice: true
  installRappcatalogueservice: true
  installRappcatalogueEnhancedservice: true
  installNonrtricgateway: true
  installKong: false
  installDmaapadapterservice: true
  installDmaapmediatorservice: true
  installHelmmanager: true
  installOruclosedlooprecovery: true
  installOdusliceassurance: true
  installCapifcore: true
  installRanpm: true
  
   volume1:
    # Set the size to 0 if you do not need the volume (if you are using Dynamic Volume Provisioning)
    size: 2Gi
    storageClassName: pms-storage
  volume2:
     # Set the size to 0 if you do not need the volume (if you are using Dynamic Volume Provisioning)
    size: 2Gi
    storageClassName: ics-storage
  volume3:
    size: 1Gi
    storageClassName: helmmanager-storage

...
...
...  