# RIC Infrastructure Support
  
Helm charts, configuration files, and automation scripts that deploy a development enviroment for RIC.
A developer should start from here to create a kubernetes cluster that is pre-configured for RIC.
Such a development cluster is mimicking a closed field-trial environment. 


### Directory Structure
.
├── 00-Kubernetes             Contains scripts to deploy K8S cluster
├── 10-Nexus                  Contains scripts and helm charts to deploy the docker registry and helm repo
├── 20-Monitoring             Helm charts for installed ELFK stack
├── 40-Credential             Helm charts to onboard credential and secrets for docker registry and helm repo
└── README.md                 This file


### To deploy the Kubernetes cluster
```sh
$ # Modify the configuration files in ./00-Kubernetes/etc/
$ . ./00-Kubernetes/bin/install
```

### To deploy Nexus repo manager
```sh
$ # Modify the configuration files in ./10-Nexus/etc/
$ . ./10-Nexus/bin/install
```


### Nexus Deployment Options
You can configure the Helm release name, Kubernetes namespace, and specify ingress controller port using configuration
files located in ./10-Nexus/etc/

In the one-click deployment solution, the above setting will be overrided by environment variables shown below.
*RICINFRA_RELEASE_NAME
*RICINFRA_NAMESPACE
*INGRESS_PORT


### Passing credential to RIC
The installation process of the Nexus repo manager will generate certificates and credential for docker registry and
helm repo.

### To deploy ELFK stack
```sh
$ # Modify the configuration files in ./20-Monitoring/etc/
$ . ./20-Monitoring/bin/install
```


### To onboard credentials
```sh
$ # Modify the user name and password in ./40-Credential/helm/values.yaml
$ # Alternatively, include the credential information in an override value yaml file
$ . ./40-Credential/bin/install
$ # If you have an override value.yaml file, please use
$ #. ./40-Credential/bin/install YOUR_OVERRIDE_FILE
```

### Credential Deployment Options
You can configure the Helm release name, Kubernetes namespace using configuration files located in ./40-Credential/etc/
Please make sure that the namespace is the same one as the one used for RIC platform components.



TODO: Fill in the details about how to pass the credential to RIC 
