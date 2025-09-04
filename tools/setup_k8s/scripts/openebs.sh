################################################################################
#   Copyright (c) 2025 Broadband Multimedia Wireless Lab, NTUST                #                                
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

helm repo add openebs https://openebs.github.io/openebs
helm repo update
helm upgrade --install openebs --namespace openebs openebs/openebs \
    --version 4.3.0 \
    --create-namespace \
    --set engines.replicated.mayastor.enabled=false \
    --set engines.local.lvm.enabled=false \
    --set engines.local.zfs.enabled=false \
    --set loki.enabled=false \
    --set alloy.enabled=false \
    --wait

kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'