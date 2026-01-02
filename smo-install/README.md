# O-RAN SMO Package

## Summary
This project uses different helm charts from different Linux Foundation projects and integrate them into a unique SMO deployment.
<p>The ONAP and ORAN project helm charts are built and then configured by using "helm override" so that it represents a valid ORAN SMO installation.</p>
<p>It contains also provisioning scripts that can be used to bootstrap the platform and execute test use cases, network simulators, a1 simulators, cnf network simulators, etc ... </p>

## Table of Contents
1. [Pre-requisites](#pre-requisites)
2. [Installation Flavours](#installation-flavours-and-configurations)
3. [Installation Modes](#installation-modes)
    - [Release/Snapshot Mode](#releasesnapshot-mode-installation)
    - [Dev Mode](#dev-mode-installation)
4. [Uninstallation](#uninstallation)
5. [Manual Image Pulling](#manual-image-pulling)
6. [Troubleshooting](#troubleshooting)

---

## Pre-requisites
- VM: 64GB Memory, 20VCPU, 100GB disk
- Helm 3.12.0+ (< 4.0.0)
- Kubernetes 1.30+
- Helm deploy/undeploy plugin
- Helm cm-push plugin
- yq
- jq

---

## Installation Flavours and Configurations

- Flavours are directories under `smo-install/helm-override/`.
- The default flavour is `default` (`smo-install/helm-override/default`).
- The default flavour is considered as a baseline configuration for all the installations.
- Flavour config files:
    - `onap-override.yaml`: ONAP components
    - `oran-override.yaml`: O-RAN components
- To create a new flavour, add a directory with `onap-flavour-config.yaml` and `oran-flavour-config.yaml`.
- These flavour configuration files doesn't needs to have entire configuration as same as in default flavour, Instead it should contain only the configuration that needs to be overridden from the default flavour.
- Only override necessary config values from the default flavour.

> [!IMPORTANT]
> Each flavour may require its own prerequisites or additional configuration (for example: different cluster resources, storage classes, or external services). Please check the `README.md` file inside the flavour directory under `smo-install/helm-override/<FLAVOUR>/README.md` for flavour-specific prerequisites and configuration details before installing.

**Example:** To disable NONRTRIC rAppmanager in your flavour:
```yaml
nonrtric:
  installrAppmanager: false
```

---

## Installation Modes

### Release/Snapshot Mode Installation
- Uses pre-built charts from Nexus repositories.
- No chart building required.

**Repositories:**
- SMO Release: https://nexus3.o-ran-sc.org/repository/helm.release/
- SMO Snapshot: https://nexus3.o-ran-sc.org/repository/helm.snapshot/
- Strimzi: strimzi.io/charts/

**Steps:**
1. Clone the repository:
    ```bash
    git clone --recursive "https://gerrit.o-ran-sc.org/r/it/dep"
    ```
2. Setup Helm and plugins:
    ```bash
    ./dep/smo-install/scripts/layer-0/0-setup-helm3.sh
    ```
3. To speed up installation, the required images can be pulled manually before starting the installation. Refer to [Manual Image Pulling](#manual-image-pulling) section for details.
4. Deploy SMO:
    - Default flavour, release mode:
        ```bash
        ./dep/smo-install/scripts/layer-2/2-install-oran.sh
        ```
    - Default flavour, snapshot mode:
        ```bash
        ./dep/smo-install/scripts/layer-2/2-install-oran.sh default snapshot
        ```
    - Specific flavour, release mode:
        ```bash
        ./dep/smo-install/scripts/layer-2/2-install-oran.sh <FLAVOUR>
        ```
    - Specific flavour, snapshot mode:
        ```bash
        ./dep/smo-install/scripts/layer-2/2-install-oran.sh <FLAVOUR> snapshot
        ```
5. Verify pods:
    ```bash
    kubectl get pods -n onap && kubectl get pods -n nonrtric && kubectl get pods -n smo
    ```

### Dev Mode Installation
- Builds charts from source.

**Steps:**
1. Clone the repository:
    ```bash
    git clone --recursive "https://gerrit.o-ran-sc.org/r/it/dep"
    ```
2. Setup chartmuseum and Helm:
    ```bash
    ./dep/smo-install/scripts/layer-0/0-setup-charts-museum.sh
   ```
    ```bash
    ./dep/smo-install/scripts/layer-0/0-setup-helm3.sh
    ```
3. Build charts:
    ```bash
    ./dep/smo-install/scripts/layer-1/1-build-all-charts.sh
    ```
4. To speed up installation, the required images can be pulled manually before starting the installation. Refer to [Manual Image Pulling](#manual-image-pulling) section for details.
5. Deploy SMO:
    - Default flavour:
        ```bash
        ./dep/smo-install/scripts/layer-2/2-install-oran.sh default dev
        ```
    - Specific flavour:
        ```bash
        ./dep/smo-install/scripts/layer-2/2-install-oran.sh <FLAVOUR> dev
        ```
6. Verify pods:
    ```bash
    kubectl get pods -n onap && kubectl get pods -n nonrtric && kubectl get pods -n smo
    ```

---

## Uninstallation
To remove all components:
```bash
./dep/smo-install/scripts/uninstall-all.sh
```

---
## Manual Image Pulling
At times, the installation may be slower due to slow image pulls. To mitigate this, you can manually pull the required images before starting the installation.

To generate the list of required images, run:
```bash
./dep/smo-install/scripts/sub-scripts/generate-image-list.sh <HELM_REPO>
```
Where `<HELM_REPO>` is either `oran-snapshot` or `oran-release` or `local` (depends on the helm repo configuration). The default is `oran-release`.

Command to pull the image depends on your container runtime.

For example, if you are using `docker`, you can run:
```bash
docker pull <IMAGE_NAME>
```
Where `<IMAGE_NAME>` is the image uri from the generated list.

If you are using `containerd`, and `crictl` is available, you can run:
```bash
crictl pull <IMAGE_NAME>
```

Similarly, for other container runtimes, use the appropriate command to pull the images.

> [!NOTE]
> If you are using multi node cluster, you need to pull the images on all the nodes.

---

## Troubleshooting
> [!WARNING]
> **ONAP mariadb pod may fail to start due to slow image pulls.**
> - Try re-installation.
> - Manually pull required images before installation if issues persist. Refer to [Manual Image Pulling](#manual-image-pulling) section for details.

---
