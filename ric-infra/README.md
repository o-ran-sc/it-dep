# RIC Infrastructure Support
  
Helm charts, configuration files, and automation scripts that deploy a development enviroment for RIC.
A developer should start from here to create a kubernetes cluster that is pre-configured for RIC.
Such a development cluster is mimicking a closed field-trial environment. 


### Directory Structure
.
├── 00-Kubernetes             Contains scripts to deploy K8S cluster
├── 15-Chartmuseum            Contains scripts and helm charts to deploy the Helm chart museum
├── 20-Monitoring             Helm charts for installing ELFK stack
├── 30-Kong                   Helm charts for installing Kong Proxy/Ingress Controller
├── 40-Credential             Helm charts to onboard credential and secrets for docker registry and helm repo
├── 45-Tiller                 
└── README.md                 This file


### To deploy the Kubernetes cluster
```sh
$ # Modify the configuration files in ./00-Kubernetes/etc/
$ . ./00-Kubernetes/bin/install
```


### To deploy the Chartmuseum
```sh
$ # An override file must be used.
$ # Modify the override file, for example ../RECIPE_EXAMPLE/RIC_INFRA_RECIPE_EXAMPLE
$ #. ./15-Chartmuseum/bin/install -f YOUR_OVERRIDE_FILE
$ # To uninstall,
$ . ./15-Chartmuseum/bin/uninstall
```


### To deploy ELFK stack
```sh
$ # An override file must be used.
$ # Modify the override file, for example ../RECIPE_EXAMPLE/RIC_INFRA_RECIPE_EXAMPLE
$ . ./20-Monitoring/bin/install -f YOUR_OVERRIDE_FILE
$ # To uninstall,
$ . ./20-Monitoring/bin/uninstall
```


### To deploy Kong
```sh
$ # An override file must be used.
$ # Modify the override file, for example ../RECIPE_EXAMPLE/RIC_INFRA_RECIPE_EXAMPLE
$ . ./30-Kong/bin/install -f YOUR_OVERRIDE_FILE
$ # To uninstall,
$ . ./30-Kong/bin/uninstall
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


### To deploy an additional Tiller for xapp deployment
```sh
$ # An override file must be used.
$ # Modify the override file, for example ../RECIPE_EXAMPLE/RIC_INFRA_RECIPE_EXAMPLE
$ . ./45-Tiller/bin/install -f YOUR_OVERRIDE_FILE
$ # To uninstall,
$ . ./45-Tiller/bin/uninstall
```

