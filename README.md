<!---

Copyright (c) 2019  Intellectual Property.

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

[comment]: <> (   Copyright (c) 2019 AT&T Intellectual Property.                    ) 
[comment]: <> (   Licensed under the Creative Commons License, Attribution 4.0 Intl. (the
[comment]: <> (   "License") 
[comment]: <> (   you may not use this file except in compliance with the License.  
[comment]: <> (   You may obtain a copy of the License at                                    #
[comment]: <> (                                                                              #
[comment]: <> (       http://www.apache.org/licenses/LICENSE-2.0                             #
#                licensedunder the Creative Commons License, Attribution 4.0 Intl. (the"Documentation License"); you may not use this documentation except incompliance with the Documentation License. You may obtain a copy of theDocumentation License athttps://creativecommons.org/licenses/by/4.0/

                                                                 #
#   Unless required by applicable law or agreed to in writing, software        #
#   distributed under the License is distributed on an "AS IS" BASIS,          #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
#   See the License for the specific language governing permissions and        #
#   limitations under the License.                                             #


This is a comment, it will not be included)
[comment]: <> (in  the output file unless you use it in)
[comment]: <> (a reference style link.)


# RIC Integration
  
This repo contains RAN Intelligent Controller (RIC) deployments related files.


### Overview

The RIC deployment scripts are designed to deploy RIC components using helm charts. A deployment recipe yaml file that
contains parameter key:value pairs can be provided as a parameter for any deployment script in this repository. The
deployment recipe is acting as the helm override values.yaml file. If no deployment recipe is provided, default parameters
are used. The default parameters are set up to deploy a RIC instance using Linux Foundation repositories in a
self-contained environment. 


### Directory Structure
.
├── bin
├── ci
├── etc
├── LICENSES.txt	License information
├── README.md           This file
├── RECIPE_EXAMPLE	Directory that contains deploy recipe examples
├── ric-aux		Deployment scripts, charts and configuration files for RIC auxilary functions
├── ric-common		Deployment scripts, charts and configuration files for RIC common template
├── ric-infra		Deployment scripts, charts and configuration files for infrastructure support
├── ric-platform	Deployment scripts, charts and configuration files for RIC platform components
└── ric-xapps		xApp related scripts, charts and configuration files

### Directory Naming Convention

The root directories are organized according to the deployment plans. Each directory contains subdirectories for
different deployable components. The prefixes of these subdirectories represent the deployment order. The smaller the
prefix number the eariler the corresponding component will be deployed.  Consider the following example,
├── ric-aux
│   ├── 80-Auxiliary-Functions
│   ├── 85-Ext-Services
│   └── README.md
├── ric-infra
│   ├── 00-Kubernetes
│   ├── 10-Nexus
│   ├── 20-Monitoring
│   ├── 30-Kong
│   ├── 40-Credential
│   ├── 45-Tiller
│   └── README.md
├── ric-platform
│   ├── 50-RIC-Platform
│   ├── 55-Ext-Services
│   └── README.md
├── ric-aux
│   ├── 80-Auxiliary-Functions
│   ├── 85-Ext-Services
│   └── README.md
└── ric-xapps
    ├── 90-xApps
    └── README.md

when deploying the ric-platform, the credential is deployed before RIC-Platform.

In each of the component directories, ./bin contains the binary and script files and ./helm contains the helm charts,

Some components contain an ./etc directory with configuration files and some contain a ./docker directory with docker related files for building the docker images.

Please refer to the README.md files in individual directory for more details.

Within ric-infra, ric-platform and ric-aux, each of the components above can be deployed and undeployed separately.
There are also scripts for deploying the ric-infra, ric-platform or ric-aux in its entirety.

The ./bin directory contains these scripts

The following sections discuss one-script deployment for each

### To deploy RIC Infrastructure

Edit ./RECIPE_EXAMPLE/RIC_INFRA_RECIPE_EXAMPLE
You can choose whether to enable Kubernetes deployment, Helm Chart museum and ELFKP stack
You can specify the Helm release prefix and namespaces used
You must specify username and password for Docker repo
Then run the following to deploy:
```sh
$ . ./deploy-ric-infra -f ../RECIPE_EXAMPLE/RIC_INFRA_RECIPE_EXAMPLE
```
Run the following to undeploy:
```sh
$ . ./undeploy-ric-infra 
```

### To deploy RIC Platform

Edit ./RECIPE_EXAMPLE/RIC_PLATFORM_RECIPE_EXAMPLE
You can specify the Helm release prefix and namespaces used
Set the values of extsvcaux/ricip and extsvcaux/auxip to be the external IP addresses of VM hosting RIC cluster and VM hosting AUX cluster, respectively.
These values should be set in both the override file and the local values.yaml file
```sh
$ . ./deploy-ric-platform -f ../RECIPE_EXAMPLE/RIC_PLATFORM_RECIPE_EXAMPLE
```
Run the following to undeploy:
```sh
$ . ./undeploy-ric-platform 
```

### To deploy RIC Auxiliary functions

Edit ./RECIPE_EXAMPLE/RIC_PLATFORM_RECIPE_EXAMPLE
You can specify the Helm release prefix and namespaces used
Set the values of extsvcaux/ricip and extsvcaux/auxip to be the external IP addresses of VM hosting RIC cluster and VM hosting AUX cluster, respectively.
These values should be set in both the override file and the local values.yaml file
```sh
$ . ./deploy-ric-aux -f ../RECIPE_EXAMPLE/RIC_AUX_RECIPE_EXAMPLE
```
Run the following to undeploy:
```sh
$ . ./undeploy-ric-aux 
```
