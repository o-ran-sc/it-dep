#!/bin/bash
#
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


# the following script replaces templates in a script with env variables defined in etc folder
# when running without specifying a script, the default is to use the heat/scripts/k8s-vm-install.sh,
# the result which is a script that can be used as cloud-init script and the initial installation
# script that turns a newly launched VM into a single node k8s cluster with Helm.

usage() {
    echo "Usage: $0 <template file>" 1>&2;
    echo "   If the template file is supplied, the template file is processed;" 1>&2;
    echo "   Otherwise the k8s_vm_install.sh file under heat/script is used as template." 1>&2;
    exit 1;
}


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
set -a
RCS="$(find $DIR/../etc -maxdepth 1 -type f)"
for RC in $RCS; do
  echo "reading in values in $RC"
  source $RC
done
set +a


if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

HEAT_DIR="$WORKSPACE/tools/k8s/heat"
BIN_DIR="$WORKSPACE/tools/k8s/bin"
ETC_DIR="$WORKSPACE/tools/k8s/etc"
ENV_DIR="$WORKSPACE/tools/k8s/heat/env"

if [ -z "$1" ]; then
  TMPL="${HEAT_DIR}/scripts/k8s_vm_install.sh"
else
  TMPL="$1"
fi


if [ -z "$__RUNRICENV_GERRIT_HOST__" ]; then
   export __RUNRICENV_GERRIT_HOST__=$gerrithost
fi
if [ -z "$__RUNRICENV_GERRIT_IP__" ]; then
   export __RUNRICENV_GERRIT_IP__=$gerritip
fi
if [ -z "$__RUNRICENV_DOCKER_HOST__" ]; then
   export __RUNRICENV_DOCKER_HOST__=$dockerregistry
fi
if [ -z "$__RUNRICENV_DOCKER_IP__" ]; then
   export __RUNRICENV_DOCKER_IP__=$dockerip
fi
if [ -z "$__RUNRICENV_DOCKER_PORT__" ]; then
   export __RUNRICENV_DOCKER_PORT__=$dockerport
fi
if [ -z "$__RUNRICENV_DOCKER_USER__" ]; then
   export __RUNRICENV_DOCKER_USER__=$dockeruser
fi
if [ -z "$__RUNRICENV_DOCKER_PASS__" ]; then
   export __RUNRICENV_DOCKER_PASS__=$dockerpassword
fi
if [ -z "$__RUNRICENV_DOCKER_CERT__" ]; then
   export __RUNRICENV_DOCKER_CERT__=$dockercert
fi
if [ -z "$__RUNRICENV_DOCKER_CERT_LEN__" ]; then
   export __RUNRICENV_DOCKER_CERT_LEN__=$(echo $dockercert | wc -c)
fi
if [ -z "$__RUNRICENV_HELMREPO_HOST__" ]; then
   export __RUNRICENV_HELMREPO_HOST__=$helmrepo
fi
if [ -z "$__RUNRICENV_HELMREPO_PORT__" ]; then
   export __RUNRICENV_HELMREPO_PORT__=$helmport
fi
if [ -z "$__RUNRICENV_HELMREPO_IP__" ]; then
   export __RUNRICENV_HELMREPO_IP__=$helmip
fi
if [ -z "$__RUNRICENV_HELMREPO_USER__" ]; then
   export __RUNRICENV_HELMREPO_USER__=$helmuser
fi
if [ -z "$__RUNRICENV_HELMREPO_PASS__" ]; then
   export __RUNRICENV_HELMREPO_PASS__=$helmpassword
fi
if [ -z "$__RUNRICENV_HELMREPO_CERT__" ]; then
   export __RUNRICENV_HELMREPO_CERT__=$helmcert
fi
if [ -z "$__RUNRICENV_HELMREPO_CERT_LEN__" ]; then
   export __RUNRICENV_HELMREPO_CERT_LEN__=$(echo $helmcert | wc -c)
fi


filename=$(basename -- "$TMPL")
extension="${filename##*.}"
filename="${filename%.*}"

envsubst '${__RUNRICENV_GERRIT_HOST__}
          ${__RUNRICENV_GERRIT_IP__}
          ${__RUNRICENV_DOCKER_HOST__}
          ${__RUNRICENV_DOCKER_IP__}
          ${__RUNRICENV_DOCKER_PORT__}
          ${__RUNRICENV_DOCKER_USER__}
          ${__RUNRICENV_DOCKER_PASS__}
          ${__RUNRICENV_DOCKER_CERT__}
          ${__RUNRICENV_DOCKER_CERT__}
          ${__RUNRICENV_DOCKER_CERT_LEN__}
          ${__RUNRICENV_HELMREPO_HOST__}
          ${__RUNRICENV_HELMREPO_PORT__}
          ${__RUNRICENV_HELMREPO_IP__}
          ${__RUNRICENV_HELMREPO_CERT__}
          ${__RUNRICENV_HELMREPO_CERT_LEN__}
          ${__RUNRICENV_HELMREPO_USER__}
          ${__RUNRICENV_HELMREPO_PASS__}' < "$TMPL" > "$filename"

# fill values that are supplied by Heat stack deployment process as much as we can
sed -i -e "s/__docker_version__/${INFRA_DOCKER_VERSION}/g" "$filename"
sed -i -e "s/__k8s_version__/${INFRA_K8S_VERSION}/g" "$filename"
sed -i -e "s/__k8s_cni_version__/${INFRA_CNI_VERSION}/g" "$filename"
sed -i -e "s/__helm_version__/${INFRA_HELM_VERSION}/g" "$filename"
sed -i -e "s/__k8s_mst_private_ip_addr__/\$(hostname -I)/g" "$filename"
sed -i -e "s/__host_private_ip_addr__/\$(hostname -I)/g" "$filename"
#sed -i -e "s/__k8s_mst_floating_ip_addr__/\$(ec2metadata --public-ipv4)/g" "$filename"
sed -i -e "s/__k8s_mst_floating_ip_addr__/\$(curl ifconfig.co)/g" "$filename"
sed -i -e "s/__stack_name__/\$(hostname)/g" "$filename"
#echo "__mtu__" > /opt/config/mtu.txt
#echo "__cinder_volume_id__" > /opt/config/cinder_volume_id.txt

# because cloud init user data has a 16kB limit, remove all comment lines to save space.
# except for the #! line
sed -i -e '/^[ \t]*#[^!]/d' "$filename"

chmod +x "$filename"

K8SV=$(echo ${INFRA_K8S_VERSION} | cut -f 1-2 -d '.' | sed -e 's/\./_/g')
HV=$(echo ${INFRA_HELM_VERSION} | cut -f 1-2 -d '.' | sed -e 's/\./_/g')
DV=$(echo ${INFRA_DOCKER_VERSION} | cut -f 1-2 -d '.' | sed -e 's/\./_/g')
mv "$filename" ./k8s-1node-cloud-init-k_${K8SV:-cur}-h_${HV:-cur}-d_${DV:-cur}.sh
