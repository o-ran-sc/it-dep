# RIC Auxiliary Functions
  
Helm charts, configuration files, and automation scripts that deploy the auxiliary functions for RIC. The auxiliary
functions are defined as the features and services that interact with the RIC but are not collocated with the RIC
cluster. These functions includes but not limited to non-realtime management components (e.g., dashboard, DMaaP,
VEScollector) that interact with RIC using A1/O1 interfaces. 


### Directory Structure
.
├── 80-Auxiliary-Functions    Contains components that interact with RIC through A1/O1
│   ├── bin                   Contains deployment and uninstall scripts
│   └── helm                  Contains helm charts
├── 85-External Services      Deployment scripts and chart for external service used by RIC to reach services outside of cluster
└── README.md                 This file


### To deploy the Auxiliary Functions
```sh
$ # An override file must be used.
$ # Modify the override file, for example ../RECIPE_EXAMPLE/RIC_AUX_RECIPE_EXAMPLE
$ #. ./80-Auxiliary-Functions/bin/install -f YOUR_OVERRIDE_FILE
```


### To undeploy the Auxiliary Functions
```sh
$ . ./80-Auxiliary-Functions/bin/uninstall
```


### Deployment Options
You can configure the Helm release name, Kubernetes namespaces using the override file with
parameters global.releasePrefix and global.namespace


### To deploy the External services
The IP address described below should be the interface IP address of the VM hosting the platform cluster.
If the platform cluster is multi-node, any of the nodes can be specified here.

```sh
$ # An override file must be used.
$ # Modify the override file, for example ../RECIPE_EXAMPLE/RIC_AUX_RECIPE_EXAMPLE
$ # Set the values of extsvcaux/ricip and extsvcaux/auxip to be the external IP addresses of VM hosting RIC cluster and VM hosting AUX cluster, respectively.
$ # These values should be set ih the override file.
$ . ./85-Ext-Services/bin/install -f YOUR_OVERRIDE_FILE
```


### To undeploy the External services
```sh
$ . ./85-Ext-Services/bin/uninstall
```