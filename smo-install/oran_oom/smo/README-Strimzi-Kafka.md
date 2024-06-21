# SMO

This installation currently deploys the TEIV in a namespace "smo" and it contains the template files required to create a SMO application which needs to be written outside ONAP namespace.

## Usage of ONAP Strimzi Kafka
This installation uses the ONAP Strimzi kafka for it's operation. This is suitable when the data needs to be shared from the components in ONAP namespace or vice-versa.

### Operators in ONAP Strimzi Kafka
ONAP Strimzi kafka runs two operatos as described below.

#### Cluster Operator
It is responsible for watching all namespaces for the CR type "Kafka" and act on it when required

#### Entity Operator
It is responsible for watching the CR type "KafkaUser" and "KafkaTopic". This operator can watch only one namespace and it is configured to watch the "onap" namespace.

During the reconcilation process the entity operator may create a secret based on the "KafkaUser" configuration. This secret will get created in the namespace where the entity operator is running("onap" in this case).

##  How to use ONAP Strimzi Kafka from application
Helm template configuration required to create KafkaUser and KafkaTopic is available as part of "smo-common" chart. Each application should create the required KafkaUser and KafkaTopic based on the requirements.

<strong>KafkaUser and KafkaTopic resources should be created in "onap" namespace</strong>. Namespace "smo" is not watched by any entity operator for the CR KafkaUser and KafkaTopic.

This leads to the state where the secrets required by the application gets created in the "onap" namespace. As the secrect cannot be shared across the namespaces, it should be copied to the "smo" namespace.

The Configuration file "smo-install/helm-override/default/oran-override.yaml" contains a section where the secrets can be specified to get copied from "onap" namespace to "smo" namespace.


## Alternate options

### Sharing the Strimzi cluster across namespace
This is not supported by Strimzi Kafka at the moment. Even though access to Kafka is allowed from different namespace. KafkaUser and KafkaEntity resources are watched in only one namespace. Hence create these CR's in different namespace doesn't have any impact.

### Running a Kafka Cluster on "smo" namespace
Strimzi suggests to create one kafka cluster per namespace. In this case each namespace should create it's own kafka and zookeeper and the entity operator, So it can watch the CR changes and act on it.

This approach removes the possibility of sharing data across the smo components.

### Using KafkaMirror2 for replication
This requires running kafka cluster on the required namespaces. It provides the configuration, using which the topic can be replicated between source and target Kafka clusters. This duplicates the data and it requires a KafkaUser to be created in each cluster for the replication purpose.


### Using a topic/user operator standalone deployment
Strimzi provides an options to deploy topic/user operator in a standalone manner, so that the CR's in each of the namespaces can be managed. But this method is not meant to be used with the strimzi cluster operator managed deployments.
This is suitable for the deployments where strimzi get deployed in a standalone manner.


