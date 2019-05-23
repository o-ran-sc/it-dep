# RIC Infrastructure Support
  
Helm charts, configuration files, and automation scripts that deploy a development enviroment for RIC.
A developer should star from here to create a kubernetes cluster that is pre-configured for RIC.
Such development cluster is mimicking a closed field-trial environment. 



### Directory Structure
.
├── 00-Kubernetes             Contains scripts to deploy K8S cluster
├── 10-Nexus                  Contains scripts and helm charts to deploy the docker registry and helm repo
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

TODO: Fill in the details about how to pass the credential to RIC 
