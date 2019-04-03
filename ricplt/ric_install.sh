#!/bin/bash
################################################################################
#   Copyright (c) 2019 AT&T Intellectual Property.                             #
#   Copyright (c) 2019 Nokia.                                                  #
#                                                                              #
#   Licensed under the Apache License, Version 2.0 (the "License");            #
#   you may not use this file except in compliance with the License.           #
#   You may obtain a copy of the License at                                    #
#                                                                              #
#       http://www.apache.org/licenses/LICENSE-2.0                             #
#                                                                              #
#   Unless required by applicable law or agreed to in writing, software        #
#   distributed under the License is distributed on an "AS IS" BASIS,          #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
#   See the License for the specific language governing permissions and        #
#   limitations under the License.                                             #
################################################################################


if [ -z "$RICPLT_RELEASE_NAME" ] || \
   [ -z "$RICPLT_COMPONENTS" ] || \
   [ -z "$RICPLT_NAMESPACE" ] || \
   [ -z "$RICPLT_APPMGR_EXT_PORT" ] || \
   [ -z "$RICPLT_E2MGR_EXT_PORT" ]; then
  echo "RICPLT_RELEASE_NAME or RICPLT_COMPONENTS or RICPLT_NAMESPACE or "
  echo "RICPLT_APPMGR_EXT_PORT or RICPLT_E2MGR_EXT_PORT unset, loading "
  echo "values from ric_env.sh"
  . ./ric_env.sh
fi


RICPLT_DEPLOYMENT="$RICPLT_RELEASE_NAME"
echo "Deplot RIC Platform components [$RICPLT_COMPONENTS] to"
echo "name space: $RICPLT_NAMESPACE, Helm release: $RICPLT_DEPLOYMENT"


rm -rf dist
mkdir -p dist/packages

helm serve --repo-path dist/packages &

sleep 1

helm repo add local http://127.0.0.1:8879

helm repo update
helm package -d dist/packages common
helm repo index dist/packages


for c in common preric $RICPLT_COMPONENTS  ric; do
  echo "Preparing chart for comonent $c"
  helm repo update
  if [ -e "$c/requirements.yaml" ]; then
    helm dep up "$c"
  fi
  helm package -d dist/packages "$c"
  helm repo index dist/packages
  echo
done

helm repo update
helm install local/preric --namespace "${RICPLT_NAMESPACE}" --name pre-"${RICPLT_RELEASE_NAME}"

helm repo update
helm install local/ric --namespace "${RICPLT_NAMESPACE}" --name "${RICPLT_RELEASE_NAME}" --set appmgr.appmgr.service.appmgr.extport="${RICPLT_APPMGR_EXT_PORT}" --set e2mgr.e2mgr.service.http.extport="${RICPLT_E2MGR_EXT_PORT}"


