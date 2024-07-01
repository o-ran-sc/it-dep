<!---

Copyright (C) 2024 OpenInfra Foundation Europe. All rights reserved.


Licensed under the Creative Commons License, Attribution 4.0 Intl.
(the"Documentation License"); you may not use this documentation
except incompliance with the Documentation License. You may obtain
a copy of the Documentation License at

    https://creativecommons.org/licenses/by/4.0/

Unless required by applicable law or agreed to in writing,
documentation distributed under the Documentation License is
distributed on an "AS IS"BASIS, WITHOUT WARRANTIES OR CONDITIONS
OF ANY KIND, either express or implied. See the Documentation
License for the specific language governing permissions and
limitations under the Documentation License.

-->

# Service Manager Preload

## Running

Once the deployment has created the Kubernetes services, you can run the following script.

```sh
servicemanager-preload.sh [config.yaml]
```
where [config.yaml] is an optional config file. If this arguement is not specified, the default is config.yaml. This file is expected to be in the same directory as the `servicemanager-preload.sh` script. You can call the command without arguements as below.

```sh
servicemanager-preload.sh
```
## Script Action

1. The script runs through the provided config.yaml file and selects the root entries in the yaml as Kubernetes service names.
1. For each service, we check if the service exists, using `kubectl get service` for both the nonrtric and onap namespaces.
1. If the service is exists, we add it to a list, `running_services_list`.
1. Next, we run through all entries in the supplied yaml file.
1. If the service is on the `running_services_list`, we build a payload from the entries for that yaml item.
1. For each service in the yaml, we have an array of ports, and each port has a port number and a name. This information is used to build the payload.
1. We use the payload to call the Service Manager. This in turn calls Kong and Capif to set up the service.
