# RIC Platform Components
  
Helm charts, deployment scripts and configuration files for RIC platform components.

### Directory Structure
.
├── 50-RIC-Platform      Deployment scripts, charts and configuration files for RIC platform components
├── 55-Ext-Services      Deployment scripts and chart for external service used by RIC to reach services outside of cluster
└── README.md            This file


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
```

### To Deploy External services
The IP address described below should be the interface IP address of the VM hosting the aux cluster.
If the aux cluster is multi-node, any of the nodes can be specified here.

```sh
$ # Set the value of ext/ip in values.yaml to be the external IP address.  If you will use an override file and it has ext/ip set,
$ # make sure it is set correctly.
$ . ./55-Ext-Services/bin/install
$ # If you have an override value.yaml file, please use
$ #. ./50-Ext-Services/bin/install YOUR_OVERRIDE_FILE
```

### To Undeploy External services
```sh
$ . ./55-Ext-Services/bin/uninstall
```