#!/bin/sh

#   Copyright (c) 2019 AT&T Intellectual Property.
#   Copyright (c) 2019 Nokia.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

set -x

export ENTITIES=${ENTITIES:-helm tiller}
export KUBECONFIG=${KUBECONFIG:-/kubeconfig}
export CA_DIR=${CA_DIR:-/pki}
if [ ! -z ${TARGET_NAMESPACE} ]; then
  SECRET_NS="--namespace ${TARGET_NAMESPACE}"
else
  SECRET_NS=''
fi

if [ ! -f ${KUBECONFIG} ]; then
  export SVCACCT_NAME=${SVCACCT_NAME:-tiller}
  /bin/svcacct-to-kubeconfig.sh
fi    

if [ ! -f ${CA_DIR}/helm.key.pem -o \
     ! -f ${CA_DIR}/tiller.key.pem ]; then
 /bin/cert-gen.sh
fi    

# i'm assuming we can just lose the CA key.
for entity in ${ENTITIES}; do
 kubectl create secret generic \
  --from-file=ca.crt=/pki/ca.cert.pem \
  --from-file=tls.crt=/pki/${entity}.cert.pem \
  --from-file=tls.key=/pki/${entity}.key.pem \
  ${SECRET_NS} ${entity}
 
 kubectl label secret \
  ${SECRET_NS} ${entity} \
  app=helm \
  name=${entity}
done
