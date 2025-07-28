# O-RAN SMO Package

This project uses different helm charts from different Linux Foundation projects and integrate them into a unique SMO deployment.
<p>The ONAP and ORAN project helm charts are built and then configured by using "helm override" so that it represents a valid ORAN SMO installation.</p>
<p>It contains also provisioning scripts that can be used to bootstrap the platform and execute test use cases, network simulators, a1 simulators, cnf network simulators, etc ...</p>

# Quick Installation on existing kubernetes

## Pre-requisites:
* VM with 64GB Memory, 20VCPU, 100GB of disk space.
* Helm 3.12.0 or later
* Kubernetes 1.30 or later
* Helm deploy/undeploy plugin
* Helm cm-push plugin
* yq
* jq

## Installation flavours and configurations

### Default installation flavour
Directory `smo-install/helm-override` contains different flavours of installations. One of these flavours can be used for the installation.

The default flavour is `default` (`smo-install/helm-override/default`). It contains the configuration for the ONAP and O-RAN (NONRTRIC/SMO) components. 

`onap-override.yaml` file controls the configuration of the ONAP components.

`oran-override.yaml` file controls the configuration of the O-RAN (NONRTRIC/SMO) components.

### Creating a new flavour of installation

> [!NOTE]
> This default flavour is considered as a baseline configuration for all the installations.

Any number of flavours can be created, each flavour can have its own configuration.

Each of the new flavour should have its own directory under `smo-install/helm-override/`. 
The directory should contain the `onap-flavour-config.yaml` and `oran-flavour-config.yaml` files.

> [!IMPORTANT]
> These flavour configuration files doesn't needs to have entire configuration as same as in default flavour, Instead it should contain only the configuration that needs to be overridden from the default flavour.

For example, if you want to disable NONRTRIC rAppmanager component in your flavour, then you can have that override in your flavour's `oran-flavour-config.yaml` file as below,

```yaml
nonrtric:
  installrAppmanager: false
```
This will disable the NONRTRIC rAppmanager component in your flavour and all the other components will be installed as per the default flavour configuration.

## Release Mode Installation

This is the default mode of installation. Building the charts are not required in release mode.
Release mode uses the helm charts from the nexus helm repositories as pointed below,
* ONAP: nexus3.onap.org/repository/onap-helm-testing/
* Strimzi: strimzi.io/charts/
* NONRTRIC: ??? (nexus3.o-ran-sc.org/repository/o-ran-sc-helm/)
* SMO: ??? (nexus3.o-ran-sc.org/repository/o-ran-sc-helm/)

### Installation

Clone the repository using the command below,

```bash
git clone --recursive "https://gerrit.o-ran-sc.org/r/it/dep"
```

> [!NOTE]
> The upload of the HELM charts for NONRTRIC and SMO components is currently in progress. Until the charts are available, these components should continue to be installed using the development mode.

Use the below command to setup chartmuseum and helm,

```bash
./dep/smo-install/scripts/layer-0/0-setup-charts-museum.sh
```

```bash
./dep/smo-install/scripts/layer-0/0-setup-helm3.sh
```

Charts can be build using the below command,

```bash
./dep/smo-install/scripts/layer-1/1-build-all-charts.sh
```

Once the pre-requisites are available, The below command can be used for the smo deployment of default flavour,

```bash
./dep/smo-install/scripts/layer-2/2-install-oran.sh
```

The below command can be used for the smo deployment of a specific flavour,

```bash
./dep/smo-install/scripts/layer-2/2-install-oran.sh <FLAVOUR>
```


> [!WARNING]
> Sometimes ONAP mariadb pod may not come up properly due to the slowness in pulling the container image. In such cases, you can try with re-installation and it should work fine. Otherwise you can try to pull all the required images manually into the cluster before the installation.

Verify pods,

```bash
kubectl get pods -n onap && kubectl get pods -n nonrtric && kubectl get pods -n smo
```

## Dev Mode Installation

In this mode, the released helm charts are not used. Instead, the charts are built from the source code and installed.

### Installation

Clone the repository using the command below,

```bash
git clone --recursive "https://gerrit.o-ran-sc.org/r/it/dep"
```

Use the below command to setup chartmuseum and helm,

```bash
./dep/smo-install/scripts/layer-0/0-setup-charts-museum.sh
```

```bash
./dep/smo-install/scripts/layer-0/0-setup-helm3.sh
```

Charts can be build using the below command,

```bash
./dep/smo-install/scripts/layer-1/1-build-all-charts.sh
```

The below command can be used for the smo deployment of default flavour,

```bash
./dep/smo-install/scripts/layer-2/2-install-oran.sh default dev
```

The below command can be used for the smo deployment of a specific flavour,

```bash
./dep/smo-install/scripts/layer-2/2-install-oran.sh <FLAVOUR> dev
```

Verify pods,

```bash
kubectl get pods -n onap && kubectl get pods -n nonrtric && kubectl get pods -n smo
```

## Uninstallation:
Execute

```bash
./dep/smo-install/scripts/uninstall-all.sh
```
