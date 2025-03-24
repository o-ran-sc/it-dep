#!/bin/bash
# ============LICENSE_START=======================================================
# Copyright (C) 2025 OpenInfra Foundation Europe. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
#

# This will create a new kafka listener with oauth based authentication.
# This method will point to a keycloak installed in smo namespace for the validation.
# This will terminate the current kafka pod and restart a new one with the modified settings.
kubectl patch kafka onap-strimzi -n onap --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/kafka/listeners/-",
    "value": {
      "name": "oauth",
      "port": 9095,
      "type": "internal",
      "tls": false,
      "authentication": {
          "type": "oauth",
          "enablePlain": true,
          "maxSecondsWithoutReauthentication": 300,
          "validIssuerUri": "http://keycloak.smo:8080/realms/nonrtric-realm",
          "jwksEndpointUri": "http://keycloak.smo:8080/realms/nonrtric-realm/protocol/openid-connect/certs",
          "userNameClaim": "preferred_username"
      }
    }
  }
]'

# This will modify the authorization method used by strimzi kafka
# Existing method is "simple". This will change it to "opa" and will point to the OPA server in smo namespace
# This will terminate the current kafka pod and restart a new one with the modified settings.
# Authorization method is not per listener level. Hence this change will affect the entire strimzi cluster
# kubectl patch kafka onap-strimzi -n onap --type='merge' -p '
# spec:
#   kafka:
#     authorization: null
# '

# kubectl patch kafka onap-strimzi -n onap --type='merge' -p '
# spec:
#   kafka:
#     authorization:
#       type: opa
#       url: http://opa.smo:8181/v1/data/kafka/authz/allow
# '