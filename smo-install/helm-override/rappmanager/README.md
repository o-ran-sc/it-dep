# NONRTRIC rAppManager Helm Override

This directory contains the flavour configuration for the NONRTRIC rAppManager component.

## rAppManager 
Source code for the NONRTRIC rAppManager component is available in [`this`](https://gerrit.o-ran-sc.org/r/gitweb?p=nonrtric%2Fplt%2Frappmanager.git;a=summary) repsitory.

Sample rApps are available in the [`rapps`](https://gerrit.o-ran-sc.org/r/gitweb?p=nonrtric/plt/rappmanager.git;a=tree;f=sample-rapp-generator) directory.

Sample postman collection for rAppManager is available in [`ES Demo rApp Postman Collection`](https://github.com/o-ran-sc/nonrtric-plt-rappmanager/blob/master/sample-rapp-generator/es-demo-rapp/Demo_Energy_Saving_rApp.postman_collection.json).

> [!NOTE]
> This installation doesn't include the kserve component. If you want to install kserver based rApp, It is recommended to use the script [here](https://github.com/o-ran-sc/nonrtric-plt-rappmanager/blob/master/scripts/install/install-kserve.sh).


## Helm repository whitelisting in ONAP Policy Clamp Kubernetes Participant
The rAppManager component uses ONAP policy-clamp-ac-k8s-ppnt chart to deploy the helm charts from the rApp.

The `policy-clamp-ac-k8s-ppnt` chart requires a list of helm repositories used by rApp to be whitelisted.

This is done by adding the helm repositories to the `repoList` section in the `oran-flavour-config.yaml` file.


## rAppManager cleanup
> [!IMPORTANT]
> It is essential to clean up the rAppManager component properly after a failure to have a clean state for future deployments.

To clean up the rAppManager component, you can use follow the instructions in the [NONRTRIC rAppManager Cleanup](https://github.com/o-ran-sc/nonrtric-plt-rappmanager/tree/master/sample-rapp-generator/es-demo-rapp#clean-up).
