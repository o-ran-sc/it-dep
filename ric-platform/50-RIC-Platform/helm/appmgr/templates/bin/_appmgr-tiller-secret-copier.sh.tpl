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
if [ -x /svcacct-to-kubeconfig.sh ] ; then
 /svcacct-to-kubeconfig.sh
fi

if [ ! -z "${HELM_TLS_CA_CERT}" ]; then
  kubectl -n ${SECRET_NAMESPACE} get secret -o yaml ${SECRET_NAME} | \
   grep 'ca.crt:' | \
   awk '{print $2}' | \
   base64 -d > ${HELM_TLS_CA_CERT}
fi

if [ ! -z "${HELM_TLS_CERT}" ]; then
  kubectl -n ${SECRET_NAMESPACE} get secret -o yaml ${SECRET_NAME} | \
   grep 'tls.crt:' | \
   awk '{print $2}' | \
   base64 -d > ${HELM_TLS_CERT}
fi

if [ ! -z "${HELM_TLS_KEY}" ]; then
  kubectl -n ${SECRET_NAMESPACE} get secret -o yaml ${SECRET_NAME} | \
   grep 'tls.key:' | \
   awk '{print $2}' | \
   base64 -d > ${HELM_TLS_KEY}
fi
