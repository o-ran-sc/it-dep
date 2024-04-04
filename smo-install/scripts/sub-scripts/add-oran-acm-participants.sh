#!/bin/bash
# ============LICENSE_START=======================================================
# Copyright (C) 2024 OpenInfra Foundation Europe. All rights reserved.
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

echo "Copying ORAN ACM Participants..."

cp -r ../../oran_oom/policy-clamp-ac-dme-ppnt ../../onap_oom/kubernetes/policy/components

if ! grep -q "policy-clamp-ac-dme-ppnt" ../../onap_oom/kubernetes/policy/values.yaml; then
    cat <<EOF >> ../../onap_oom/kubernetes/policy/values.yaml
policy-clamp-ac-dme-ppnt:
  enabled: true
EOF
fi

if ! grep -q "policy-clamp-ac-dme-ppnt" ../../onap_oom/kubernetes/policy/Chart.yaml; then
    cat <<EOF >> ../../onap_oom/kubernetes/policy/Chart.yaml
  - name: policy-clamp-ac-dme-ppnt
    version: ~1.0.0
    repository: 'file://components/policy-clamp-ac-dme-ppnt'
    condition: policy-clamp-ac-dme-ppnt.enabled
EOF
fi

echo "ORAN ACM Participants copied and configured for build."