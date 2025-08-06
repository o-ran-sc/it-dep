<!---

Copyright (C) 2024-2025 OpenInfra Foundation Europe. All rights reserved.

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

## Config format
The config file follows a format that is similar to the format required by the Service Manager/CAPIFcore Publisher.

## Running

At the end of the Kubernetes deployment, following script runs automatically.

```sh
servicemanager-preload.sh [config.yaml]
```
where [config.yaml] is a config file. If this arguement is not specified, the default is config.yaml. The input file is expected to be in the same directory as the `servicemanager-preload.sh` script. You can call the command without arguements as below.

In our installation we provide 2 config files, `config-nonrtric.yaml` and `config-smo.yaml`. The file `config-nonrtric.yaml` is used by both the NONRTRIC install and SMO installs. For the SMO install we concatate both files into a file called `config-nonrtric-smo.yaml` and use that. This file is deleted after use in the installation script. We do it this way to avoid duplicating the information in `config-nonrtric.yaml`.

## Script Action

1. The script runs through the provided config.yaml file and selects the root entries in the YAML as Kubernetes service names.
1. For each service, we check if the service exists, using `kubectl get service` for both the nonrtric and onap namespaces.
1. If the service is exists, we add it to a list, `running_services_list`.
1. Next, we run through all entries in the supplied YAML file.
1. If the service is on the `running_services_list`, we build a payload from the entries for that YAML item.
1. We use the payload to call the Service Manager. This in turn calls Kong and Capif to set up the service.

## Interface Descriptions

To distinguish between multiple interface descriptions, Service Manager prepends the port number and a hash code to the URL path.

## Static and Dynamic Routes

We can specify either static or dynamic routes. Static routing defines a route when there is a single route for traffic to reach a destination. Dynamic routing allows us to specify path parameters. In this config file, we specify path parameters using regular expressions.

Kong uses the regex definition from the [Rust programming language](https://docs.rs/regex/latest/regex/) to specify the regular expression (regex) that describes the path parameters, [Kong regex](https://docs.konghq.com/gateway/latest/key-concepts/routes/#regular-expressions).

An example of a static path is as follows. This is the straightforward case.

```http
   /rapps
```

An example of a dynamic path is

```http
   ~/rapps/(?<rappId>[a-zA-Z0-9]+([-_][a-zA-Z0-9]+)*)
```

Our dynamic path starts with a ~ character. In this example, we have a path parameter that is described by a regex capture group called rappId. The regex describes a word made of mixed-case alphanumeric characters optionally followed by one or more sets of a dash or underscore together with another word.

When the Service Manager client calls a dynamic API, we call the URL without the '~'. Kong substitutes the path parameter according to the rules specified in the regex. Therefore, we can call the above example by using

```http
   /rapps/my-rApp-id
```

as the URL where my-rApp-id is the rApp id of in the rApp Manager. The name my-rApp-id has to match the regex shown above.

It is required to name the capture group in this YAML config file. The capture group name is used by Service Manager when creating a Kong Request Transformer plugin. We can specify multiple capture groups in a URL if there are multiple path parameters in the API path.

We create a Kong Request Transformer plugin with .data[].config.replace, as in the following example curl with abridged response.

```sh
curl -X GET http://oran-nonrtric-kong-admin.nonrtric.svc.cluster.local:8001/plugins
```

```json
{
  "body": [],
  "uri": "/rapps/$(uri_captures[\"rappId\"])",
  "headers": [],
  "querystring": []
}
```

In our example, this allows Kong to match /rapps/my-rApp-id. 

The Service Manager uses the following regex to search and replace the YAML file regexes.

```regex
/\(\?<([^>]+)>([^\/]+)/
```

Please note that the example path, /rapps/my-rApp-id, is not terminated by a '/'. Service Manager adds a '/' for internal matching. This made the regex easier to develop. Service Manager will match on /rapps/my-rApp-id/ for this case.
