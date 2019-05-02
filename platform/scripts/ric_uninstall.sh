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

if [ -z "$RICPLT_RELEASE_NAME" ] || [ -z "$RICPLT_COMPONENTS" ] || [ -z "$RICPLT_NAMESPACE" ]; then
  echo "RICPLT_RELEASE_NAME or RICPLT_COMPONENTS or RICPLT_NAMESPACE unset, loading from ric_env.sh"
  . ./ric_env.sh
fi

RICPLT_DEPLOYMENT="$RICPLT_RELEASE_NAME"

echo "Uninstall RIC Platform components $RICPLT_COMPONENTS"
echo "name space: $RICPLT_NAMESPACE, Helm release: $RICPLT_DEPLOYMENT"


for c in $RICPLT_COMPONENTS; do
  helm delete --purge "${RICPLT_RELEASE_NAME}-$c"
done

helm delete --purge pre-"${RICPLT_RELEASE_NAME}"

echo "It may take Kubernetes some time to release all resources created"
echo "for RIC Platform.  Use \"kubectl get pods -n ricplatform\" to check."
echo "To truely clean up the helm state, run the following command:"
echo " ./helm_reset.sh"
echo "Done"
