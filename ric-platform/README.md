# RIC Platform Components
  
Helm charts, deployment scripts and configuration files for RIC platform components.

### Directory Structure
.
├── 50-RIC-Platform      Deployment scripts, charts and configuration files for RIC platform components
│   ├── bin              Contains deployment and uninstall scripts
│   └── helm             Contains helm charts
├── 55-Ext-Services      Deployment scripts and chart for external service used by RIC to reach services outside of cluster
└── README.md            This file


In the one-click deployment solution, the above setting will be overrided by environment variables shown below.
*RICPLT_RELEASE_NAME
*RICPLT_NAMESPACE


### To Deploy RIC Platform
```sh
$ # An override file must be used.
$ # Modify the override file, for example ../RECIPE_EXAMPLE/RIC_PLATFORM_RECIPE_EXAMPLE
$ #. ./50-RIC-Platform/bin/install -f YOUR_OVERRIDE_FILE
```

### RIC Platform Deployment Options
You can configure the Helm release name, Kubernetes namespaces using the override file with
parameters global.releasePrefix and global.namespace

### To Undeploy RIC Platform
```sh
$ . ./50-RIC-Platform/bin/uninstall
```

### To Deploy External services
The IP address described below should be the interface IP address of the VM hosting the aux cluster.
If the aux cluster is multi-node, any of the nodes can be specified here.

```sh
$ # An override file must be used.
$ # Modify the override file, for example ../RECIPE_EXAMPLE/RIC_PLATFORM_RECIPE_EXAMPLE
$ # Set the values of extsvcaux/ricip and extsvcaux/auxip to be the external IP addresses of VM hosting RIC cluster and VM hosting AUX cluster, respectively.
$ # These values should be set in the override file
$ . ./55-Ext-Services/bin/install -f YOUR_OVERRIDE_FILE
```

### To Undeploy External services
```sh
$ . ./55-Ext-Services/bin/uninstall
```