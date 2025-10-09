# NONRTRIC rAppManager - Helm override configuration

This directory contains the helm override configuration for the NONRTRIC rAppManager component.

## Overview
- The rAppManager component uses ONAP's `policy-clamp-ac-k8s-ppnt` to deploy the helm charts provided by rApp packages.
- This folder holds flavour-specific configuration that overrides the default settings in the main installation.

## Source code and samples
- rAppManager source: https://gerrit.o-ran-sc.org/r/gitweb?p=nonrtric%2Fplt%2Frappmanager.git;a=summary
- Sample rApps: https://gerrit.o-ran-sc.org/r/gitweb?p=nonrtric/plt/rappmanager.git;a=tree;f=sample-rapp-generator
- Example Postman collection (ES Demo rApp): https://github.com/o-ran-sc/nonrtric-plt-rappmanager/blob/master/sample-rapp-generator/es-demo-rapp/Demo_Energy_Saving_rApp.postman_collection.json

## Prerequisites
- A helm repository configuration is required for rAppManager. See the "Helm repository configuration" section below for how to whitelist repositories used by rApps.
- KServe (for kserve-based rApps) is not installed by default in the SMO installation. If you intend to use KServe-based rApps, consider using the installer script in the rAppManager project:
  - https://github.com/o-ran-sc/nonrtric-plt-rappmanager/blob/master/scripts/install/install-kserve.sh
  - The `policy-clamp-ac-kserve-ppnt` component requires access to the Kserve CR via Kubernetes API server.

## Helm repository configuration
The `policy-clamp-ac-k8s-ppnt` chart requires a whitelist of helm repositories that rAppManager will use. To provide this whitelist:

1. Add the required repositories to the `repoList` section in your flavour's `oran-flavour-config.yaml`.
2. Ensure the listed repositories are accessible from the Kubernetes cluster where rAppManager and policy-clamp-ac-k8s-ppnt are deployed.

Access/permissions notes:
- rAppManager must be able to write to repositories where it will push or publish rApp charts.
- The policy-clamp-ac-k8s-ppnt component requires read access to the repositories to fetch and deploy rApp charts.

If you prefer to run a local helm chart repository, see the next section about the local chartmuseum setup.

### Local chartmuseum setup
In dev mode this step is performed as part of the installation. In release/snapshot mode you must install chartmuseum manually if you want to use a local chart repository.

```bash
./dep/smo-install/scripts/layer-0/0-setup-charts-museum.sh
```

Notes:
- The script installs chartmuseum on the host where it is executed.
- When using a local chartmuseum, make sure your Kubernetes cluster can reach the host IP (Where chartmuseum installed) and port `18080`.
- Form the chartmuseum URI using the host IP and port `18080` so that rAppManager and other components can access it.


## rAppManager cleanup
> [!IMPORTANT]
> It is essential to clean up the rAppManager component properly after a failure to have a clean state for future deployments.

To clean up the rAppManager component, you can use follow the instructions in the [NONRTRIC rAppManager Cleanup](https://github.com/o-ran-sc/nonrtric-plt-rappmanager/tree/master/sample-rapp-generator/es-demo-rapp#clean-up).
