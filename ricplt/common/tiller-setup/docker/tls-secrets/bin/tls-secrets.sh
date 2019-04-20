#!/bin/sh
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
  ${SECRET_NS} ${entity}-secret
 
 kubectl label secret \
  ${SECRET_NS} ${entity}-secret \
  app=helm \
  name=${entity}
done
