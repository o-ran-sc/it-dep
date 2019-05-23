# RIC Integration
  
This repo contains RAN Intelligent Controller (RIC) deployments related files.

### Directory Structure
.
├── aux                  Deployment scripts, charts and configuration files for RIC auxiliry functions
├── infra                Deployment scripts, charts and configuration files for infrastructure support
├── LICENSES.txt         License information
├── README.md            This file
├── ric-platform         Deployment scripts, charts and configuration files for RIC platform components
└── xapps                xApp related scripts, charts and configuration files

### Directory Naming Convention

The root directories are orgainzed according to the deployment plans. Each directory contains subdirectories for
different deployable components. The prefix of these subdirectories represents the deployment order. The smaller the
prefix number the eariler the corresponding component will be deployed.  Consider the following example,
.
├── aux
│   └── 80-Auxiliary-Functions
├── infra
│   ├── 00-Kubernetes
│   └── 10-Nexus
├── LICENSES.txt
├── README.md
├── ric-platform
│   ├── 20-Credential
│   └── 50-RIC-Platform
└── xapps
    └── 90-xApps
when deploys the ric-platform, the credential is deployed before RIC-Platform.

In each of the component directory, ./etc contains the configuration file, ./bin contains the binary and script files,
./helm contains the helm charts, and ./docker contains docker related files for building the docker images. Please refer
to the README.md files in individual directory for more details.

### To deploy RIC
TBD will update when we have the root installer.

### Configure the RIC deployment
TBD will update when we have the root installer.
