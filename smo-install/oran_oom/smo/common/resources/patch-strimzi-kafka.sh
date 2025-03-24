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