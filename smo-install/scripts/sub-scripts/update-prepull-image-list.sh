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

SCRIPT=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT")

echo "### Updating pre-pull image list for ONAP, ORAN SMO and NONRTRIC parts ###"
ONAP_HELM_IMAGES=$(helm template onap-app local/onap -f $SCRIPT_PATH/../../helm-override/default/onap-override.yaml | grep -v "^\s*#" | awk -F'image: ' '/image:/ {gsub(/["'\'']/, "", $2); print $2}' | sort -u)
echo "ONAP images extracted from Helm charts: $(echo "$ONAP_HELM_IMAGES" | wc -l)"

NONRTRIC_HELM_IMAGES=$(helm template nonrtric-app local/nonrtric -f $SCRIPT_PATH/../../helm-override/default/oran-override.yaml | grep -v "^\s*#" | awk -F'image: ' '/image:/ {gsub(/["'\'']/, "", $2); print $2}' | sort -u)
echo "NONRTRIC images extracted from Helm charts: $(echo "$NONRTRIC_HELM_IMAGES" | wc -l)"

SMO_HELM_IMAGES=$(helm template smo-app local/smo -f $SCRIPT_PATH/../../helm-override/default/oran-override.yaml | grep -v "^\s*#" | awk -F'image: ' '/image:/ {gsub(/["'\'']/, "", $2); print $2}' | sort -u)
echo "SMO images extracted from Helm charts: $(echo "$SMO_HELM_IMAGES" | wc -l)"

# Combine all those image list and sort and write it in a YAML file
{
    echo "# This is a generated file. Do not edit it manually."
    echo "initContainerImage:"
    {
        echo "$ONAP_HELM_IMAGES"
        echo "$NONRTRIC_HELM_IMAGES"
        echo "$SMO_HELM_IMAGES"
    } | sort -u | awk '{print "  - "$0}'
} > "$SCRIPT_PATH"/../packages/pre-configuration/pre-pull-image-list.yaml
