# RIC Auxiliary Functions
  
Helm charts, configuration files, and automation scripts that deploy the auxiliary functions for RIC. The auxiliary
functions are defined as the features and services that interact with the RIC but they do not collocated with the RIC
cluster. These functions includes but not limited to non-realtime management components (e.g., dashboard, DMaaP,
VEScollector) that interact with RIC using A1/O1 interfaces. 



### Directory Structure
.
├── 80-Auxiliary-Functions    Contains components that interact with RIC through A1/O1
│   ├── bin                   Contains deployment and uninstall scripts
│   ├── etc                   Contains deployment configuration files
│   └── helm                  Contains helm charts
└── README.md                 This file


### To deploy the Auxiliary Functions
```sh
$ # Modify the configuration files in ./80-Auxiliary-Functions/etc/
$ . ./80-Auxiliary-Functions/bin/install
$ # If you have an override value.yaml file, please use
$ #. ./80-Auxiliary-Functions/bin/install YOUR_OVERRIDE_FILE
```


### To undeploy the Auxiliary Functions
```sh
$ . ./80-Auxiliary-Functions/bin/uninstall
```


### Deployment Options
You can configure the Helm release name, Kubernetes namespace using configuration files located in ./80-Auxiliary-Functions/etc/

In the one-click deployment solution, the above setting will be overrided by environment variables shown below.
*RICAUX_RELEASE_NAME
*RICAUX_NAMESPACE

