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

# TODO: THIS SHOULD BE REMOVED ONCE the OOM POLICY CHARTS ARE UPDATED TO WORK WITH SYNC TOPIC

# This will patch the below kafka users with the new group acl
# This acl configuration gives the user permission to read from all groups

# create an array with the kafka users
kafka_users=(
  "policy-clamp-ac-a1pms-ppnt-ku"
  "policy-clamp-ac-http-ppnt-ku"
  "policy-clamp-ac-k8s-ppnt-ku"
  "policy-clamp-ac-kserve-ppnt-ku"
  "policy-clamp-ac-pf-ppnt-ku"
)

# Iterate over an array of kafka users and check whether the user exists or not
for user in "${kafka_users[@]}"; do
  if kubectl get kafkauser "$user" -n onap; then
    echo "Kafka user $user exists."
    #patch the kafka users with new group acl
    kubectl patch kafkauser "$user" -n onap --type='json' -p '[
        {
            "op": "add",
            "path": "/spec/authorization/acls/-",
            "value": {
            "resource": {
                "type": "group",
                "name": "*",
                "patternType": "literal"
            },
            "operation": "Read",
            }
        }
    ]'
  else
    echo "Kafka user $user does not exist."
  fi
done

