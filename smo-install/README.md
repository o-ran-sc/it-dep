# O-RAN SMO Package

This project uses different helm charts from different Linux Foundation projects and integrate them into a unique SMO deployment.
<p>The ONAP and ORAN project helm charts are built and then configured by using "helm override" so that it represents a valid ORAN SMO installation.</p>
<p>It contains also provisioning scripts that can be used to bootstrap the platform and execute test use cases, network simulators, a1 simulators, cnf network simulators, etc ...</p>

# Quick Installation on existing kubernetes

## Installation flavours and configurations
Directory "smo-install/helm-override" contains different flavours of installations. One of these flavours can be used for the installation.

Each directory inside "smo-install/helm-override" contains a onap-override.yaml file. It controls the configuration of the ONAP components.
and oran-override.yaml controls the configuration of the O-RAN(NONRTIRC/SMO) components.

Any number of flavours can be created each flavour can have its own configuration. It should follow the same structure as the default flavour.

The default flavour is "default".

Flavour name should be used as the directory name. It can be provided as an argument to the script.

```./dep/smo-install/scripts/layer-2/2-install-oran.sh <FLAVOUR> <MODE>```

### Pre-requisites:
* VM with 64GB Memory, 20VCPU, 60GB of disk space.
* Helm 3.12.0 or later
* Kubernetes 1.30 or later
* Helm deploy/undeploy plugin
* Helm cm-push plugin
* yq
* jq


## Release Mode Installation

This is the default mode of installation. Building the charts are not required in release mode.
Release mode uses the helm charts from the nexus helm repositories as pointed below,
* ONAP: nexus3.onap.org/repository/onap-helm-testing/
* Strimzi: strimzi.io/charts/
* NONRTRIC: ??? (nexus3.o-ran-sc.org/repository/o-ran-sc-helm/)
* SMO: ??? (nexus3.o-ran-sc.org/repository/o-ran-sc-helm/)

### Installation

Clone the repository using the command below,

```git clone --recursive "https://gerrit.o-ran-sc.org/r/it/dep"```

---
**NOTE**
The upload of the HELM charts for NONRTRIC and SMO components is currently in progress. Until the charts are available, these components should continue to be installed using the development mode.
---

Use the below command to setup chartmuseum and helm

```./dep/smo-install/scripts/layer-0/0-setup-charts-museum.sh```

```./dep/smo-install/scripts/layer-0/0-setup-helm3.sh```

Charts can be build using the below command,

```./dep/smo-install/scripts/layer-1/1-build-all-charts.sh```

Once the pre-requisites are available, The below command can be used for the smo deployment.

```./dep/smo-install/scripts/layer-2/2-install-oran.sh```

---
**WARNING**
Sometimes ONAP mariadb pod may not come up properly due to the slowness in pulling the container image. In such cases, you can try with re-installation and it should work fine. Otherwise you can try to pull all the required images manually into the cluster before the installation.
---

Verify pods:

```kubectl get pods -n onap && kubectl get pods -n nonrtric && kubectl get pods -n smo```

## Dev Mode Installation

In this mode, the released helm charts are not used. Instead, the charts are built from the source code and installed.

### Installation

Clone the repository using the command below,

```git clone --recursive "https://gerrit.o-ran-sc.org/r/it/dep"```

Use the below command to setup chartmuseum and helm

```./dep/smo-install/scripts/layer-0/0-setup-charts-museum.sh```

```./dep/smo-install/scripts/layer-0/0-setup-helm3.sh```

Charts can be build using the below command,

```./dep/smo-install/scripts/layer-1/1-build-all-charts.sh```

The below command can be used for the smo deployment.

```./dep/smo-install/scripts/layer-2/2-install-oran.sh default dev```

Verify pods:

```kubectl get pods -n onap && kubectl get pods -n nonrtric && kubectl get pods -n smo```

## Uninstallation:
* Execute

	```./dep/smo-install/scripts/uninstall-all.sh```
