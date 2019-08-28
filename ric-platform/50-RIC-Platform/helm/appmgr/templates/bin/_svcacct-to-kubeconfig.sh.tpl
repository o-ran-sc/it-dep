{{/*
   Copyright (c) 2019 AT&T Intellectual Property.
   Copyright (c) 2019 Nokia.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/}}
#!/bin/sh

# generate a kubconfig (at ${KUBECONFIG} file from the automatically-mounted
# service account token.
# ENVIRONMENT:
# SVCACCT_NAME: the name of the service account user.  default "default"
# CLUSTER_NAME: the name of the kubernetes cluster.  default "kubernetes"
# KUBECONFIG: where the generated file will be deposited.
SVCACCT_TOKEN=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
CLUSTER_CA=`base64 /var/run/secrets/kubernetes.io/serviceaccount/ca.crt|tr -d '\n'`

cat >${KUBECONFIG} <<__EOF__
ApiVersion: v1
kind: Config
users:
- name: ${SVCACCT_NAME:-default}
  user:
    token: ${SVCACCT_TOKEN}
clusters:
- cluster:
    certificate-authority-data: ${CLUSTER_CA}
    server: ${K8S_API_HOST:-https://kubernetes.default.svc.cluster.local/}
  name: ${CLUSTER_NAME:-kubernetes}
contexts:
- context:
    cluster: ${CLUSTER_NAME:-kubernetes}
    user: ${SVCACCT_NAME:-default}
  name: svcs-acct-context
current-context: svcs-acct-context
__EOF__
