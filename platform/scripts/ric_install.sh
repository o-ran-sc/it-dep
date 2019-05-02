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

OVERRIDEYAML=$1


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if [ -z "$RICPLT_RELEASE_NAME" ] || \
   [ -z "$RICPLT_COMPONENTS" ] || \
   [ -z "$RICPLT_NAMESPACE" ] || \
   [ -z "$RICPLT_APPMGR_EXT_PORT" ] || \
   [ -z "$RICPLT_E2MGR_EXT_PORT" ]; then
  echo "RICPLT_RELEASE_NAME or RICPLT_COMPONENTS or RICPLT_NAMESPACE unset, loading "
  echo "values from ric_env.sh"
  . ./ric_env.sh
fi

echo "Deploying PreRic charts to name space: $RICPLT_NAMESPACE, Helm release: pre-${RICPLT_RELEASE_NAME}"


if [ -z $OVERRIDEYAML ]; then
helm install --namespace "${RICPLT_NAMESPACE}" --name pre-"${RICPLT_RELEASE_NAME}" $DIR/../charts/preric
else
helm install -f $OVERRIDEYAML --namespace "${RICPLT_NAMESPACE}" --name pre-"${RICPLT_RELEASE_NAME}" $DIR/../charts/preric
fi


RICPLT_DEPLOYMENT="$RICPLT_RELEASE_NAME"
echo "Deplot RIC Platform components [$RICPLT_COMPONENTS] to"
echo "name space: $RICPLT_NAMESPACE, Helm release: $RICPLT_DEPLOYMENT"








COMMON_CHART_VERSION=$(cat $DIR/../charts/common/Chart.yaml | grep version | awk '{print $2}')

helm package -d /tmp $DIR/../charts/common




for c in $RICPLT_COMPONENTS; do
  echo "Preparing chart for comonent $c"
  cp /tmp/common-$COMMON_CHART_VERSION.tgz $DIR/../charts/$c/charts/
  if [ -z $OVERRIDEYAML ]; then
  helm install --namespace "${RICPLT_NAMESPACE}" --name "${RICPLT_RELEASE_NAME}-$c" $DIR/../charts/$c
  else
  helm install -f $OVERRIDEYAML --namespace "${RICPLT_NAMESPACE}" --name "${RICPLT_RELEASE_NAME}" $DIR/../charts/$c
  fi
done

