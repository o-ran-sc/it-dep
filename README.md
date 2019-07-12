# RIC Integration
  
This repo contains RAN Intelligent Controller (RIC) deployments related files.


### Overview

The RIC deployment scripts are designed to deploy RIC components using helm charts. A deployment recipe yaml file that
contains parameter key:value pairs can be provided as a parameter for any deployment script in this repository. The
deployment recipe is acting as the helm override value.yaml file. If no deployment recipe is provided, defaul parameters
are used. The default parameters are set up to deploy a RIC instance using Linux Foundation repositories in a
self-contained environment. 


### Directory Structure
.
├── bin
├── etc
├── LICENSES.txt	License information
├── README.md           This file
├── RECIPE_EXAMPLE	Directory that contains deploy recipe examples
├── ric-aux		Deployment scripts, charts and configuration files for RIC auxiliry functions
├── ric-infra		Deployment scripts, charts and configuration files for infrastructure support
├── ric-platform	Deployment scripts, charts and configuration files for RIC platform components
└── ric-xapps		xApp related scripts, charts and configuration files

### Directory Naming Convention

The root directories are orgainzed according to the deployment plans. Each directory contains subdirectories for
different deployable components. The prefix of these subdirectories represents the deployment order. The smaller the
prefix number the eariler the corresponding component will be deployed.  Consider the following example,
├── ric-aux
│   ├── 80-Auxiliary-Functions
│   ├── 85-Ext-Services
│   └── README.md
├── ric-infra
│   ├── 00-Kubernetes
│   ├── 10-Nexus
│   ├── 20-Monitoring
│   ├── 40-Credential
│   └── README.md
├── ric-platform
│   ├── 50-RIC-Platform
│   ├── 55-Ext-Services
│   └── README.md
└── ric-xapps
    ├── 90-xApps
    └── README.md
when deploys the ric-platform, the credential is deployed before RIC-Platform.

In each of the component directory, ./etc contains the configuration file, ./bin contains the binary and script files,
./helm contains the helm charts, and ./docker contains docker related files for building the docker images. Please refer
to the README.md files in individual directory for more details.

### To deploy RIC
TBD will update when we have the root installer.

### Configure the RIC deployment
TBD will update when we have the root installer.
