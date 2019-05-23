# RIC Platform Components
  
Helm charts, deployment scripts and configuration files for RIC platform components.

### Directory Structure
.
├── 20-Credential        Helm charts to onboard credential and secrets for docker registry and helm repo
├── 50-RIC-Platform      Deployment scripts, charts and configuration files for RIC platform components
└── README.md            This file

### To onboard credentials
```sh
$ # Modify the user name and password in ./20-Credential/helm/values.yaml
$ # Alternatively, include the credential information in an override value yaml file
$ . ./20-Credential/bin/install
$ # If you have an override value.yaml file, please use
$ #. ./20-Credential/bin/install YOUR_OVERRIDE_FILE
```

### Credential Deployment Options
You can configure the Helm release name, Kubernetes namespace using configuration files located in ./20-Credential/etc/
Please make sure that the namespace is the same one as the one used for RIC platform components.

In the one-click deployment solution, the above setting will be overrided by environment variables shown below.
*RICPLT_RELEASE_NAME
*RICPLT_NAMESPACE


### To Deploy RIC Platform
```sh
$ # Modify the configuration files in ./50-RIC-Platform/etc/
$ . ./50-RIC-Platform/bin/install
$ # If you have an override value.yaml file, please use
$ #. ./50-RIC-Platform/bin/install YOUR_OVERRIDE_FILE
```

### RIC Platform Deployment Options
You can configure the Helm release name, Kubernetes namespace using configuration files located in ./50-RIC-Platform/etc/
Please make sure that the namespace is the same one as the one used for RIC platform components.

In the one-click deployment solution, the above setting will be overrided by environment variables shown below.
*RICPLT_RELEASE_NAME
*RICPLT_NAMESPACE

### To Undeploy RIC Platform
```sh
$ . ./50-RIC-Platform/bin/uninstall
