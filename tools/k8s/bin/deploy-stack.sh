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

set -e 

stack_name="ric"
full_deletion=false

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
set -a
RCS="$(find $DIR/../etc -type f -maxdepth 1)"
for RC in $RCS; do
  echo "reading in values in $RC"
  source $RC
done
set +a


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


if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi
HEAT_DIR="$WORKSPACE/tools/k8s/heat"
BIN_DIR="$WORKSPACE/tools/k8s/bin"
ETC_DIR="$WORKSPACE/tools/k8s/etc"
ENV_DIR="$WORKSPACE/tools/k8s/heat/env"


cd $BIN_DIR


openstack --version > /dev/null
if [ $? -eq 0 ]; then
    echo "OK openstack CLI installed"
else
    echo "Must run in an envirnment with openstack cli"
    exit 1
fi

if [ -z "$OS_USERNAME" ]; then
    echo "Must source the Openstack RC file for the target installation tenant"
    exit 1
fi


usage() {
    echo "Usage: $0 [ -n <number of VMs {2-15}> ][ -s <stack name> ]<env> <ssh_keypair> <template>" 1>&2;
    echo "n:    Set the number of VMs that will be installed. " 1>&2;
    echo "s:    Set the name to be used for stack. This name will be used for naming of resources" 1>&2;
    echo "d:    Dryrun, only generating templates, no calling OpenStack API" 1>&2;
    echo "6:    When enabled, VMs will have an IPv6 interface." 1>&2;

    exit 1;
}


dryrun='false'
v6='false'
while getopts ":n:w:s:6d" o; do
    case "${o}" in
        n)
            if [[ ${OPTARG} =~ ^[0-9]+$ ]];then
                if [ ${OPTARG} -ge 1 -a ${OPTARG} -le 15 ]; then
                    vm_num=${OPTARG}
                else
                    usage
                fi
            else
                usage
            fi
            ;;
        s)
            if [[ ! ${OPTARG} =~ ^[0-9]+$ ]];then
                stack_name=${OPTARG}
            else
                usage
            fi
            ;;
        w)
            WORKDIR_NAME=${OPTARG}
            ;;
        6)
            v6=true
            ;;
        d)
            dryrun=true
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ "$#" -lt 2 ]; then
   usage
fi

ENV_FILE=$1
if [ ! -f $ENV_FILE ]; then
    echo ENV file does not exist or was not given
    exit 1
fi
shift 1

SSH_KEY=$1
if [ ! -s $SSH_KEY ]; then
    echo SSH Keypair file does not exist or was not given
    exit 1
fi
shift 1

if [ -z "$vm_num" ]; then
    TMPL_FILE=$1
    if [ ! -f $TMPL_FILE ]; then
        echo Heat template file does not exist or was not given
        exit 1
    fi
    shift 1
fi

# Prints all commands to output that are executed by the terminal
set -x

if [ -z "$WORKDIR_NAME" ]; then
  WORKDIR_NAME="workdir-$(date +%Y%m%d%H%M%S)"
fi
WORKDIR="$BIN_DIR/$WORKDIR_NAME"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"

# get the openstack rc file env variable values in env file
envsubst < $ENV_FILE > "$WORKDIR/$(basename $ENV_FILE)"
ENV_FILE="$WORKDIR/$(basename $ENV_FILE)"

# prepare (localize) all scripts to be installed to the cluster VMs
SCRIPTS=$(ls -1 $HEAT_DIR/scripts/*)
for SCRIPT in $SCRIPTS; do
    envsubst '${__RUNRICENV_GERRIT_HOST__}
              ${__RUNRICENV_GERRIT_IP__}
              ${__RUNRICENV_DOCKER_HOST__}
              ${__RUNRICENV_DOCKER_IP__}
              ${__RUNRICENV_DOCKER_PORT__}
              ${__RUNRICENV_DOCKER_USER__}
              ${__RUNRICENV_DOCKER_PASS__}
              ${__RUNRICENV_DOCKER_CERT__}
              ${__RUNRICENV_HELMREPO_HOST__}
              ${__RUNRICENV_HELMREPO_PORT__}
              ${__RUNRICENV_HELMREPO_IP__}
              ${__RUNRICENV_HELMREPO_CERT__}
              ${__RUNRICENV_HELMREPO_USER__}
              ${__RUNRICENV_HELMREPO_PASS__} '< $SCRIPT > "$WORKDIR/$(basename $SCRIPT)"
done
    
# generate a heat template with the specified number of VMs and IPv6 option
if [ ! -z "$vm_num" ]; then
    CURDIR=$(pwd)
    if [ -z "$v6" ]; then
        ./gen-ric-heat-yaml.sh -n $vm_num > "$WORKDIR/k8s-${vm_num}VMs.yaml"
        TMPL_FILE="$WORKDIR/k8s-${vm_num}VMs.yaml"
    else
        ./gen-ric-heat-yaml.sh -6 -n $vm_num > "$WORKDIR/k8s-${vm_num}VMs-v6.yaml"
        TMPL_FILE="$WORKDIR/k8s-${vm_num}VMs-v6.yaml"
    fi
fi

if [ "$dryrun" == "true" ]; then
    exit 0
fi


for n in $(seq 1 5); do
    echo "${n} of 5 attempts to deploy the stack $stack_name"
    FAILED='false'
    if [ ! -z "$(openstack stack list |grep -w $stack_name)" ]; then
        openstack stack delete $stack_name;
        while [ "DELETE_IN_PROGRESS" == "$(openstack stack show -c stack_status -f value $stack_name)" ]; do
            echo "Waiting for stack $stack_name deletion to complete"
            sleep 5
        done
    fi

    # create a stack with the template and env files
    if ! openstack stack create -t $TMPL_FILE -e $ENV_FILE $stack_name; then
        FAILED='true'
        break
    fi

    # wait for OpenStack stack creation completes
    while [ "CREATE_IN_PROGRESS" == "$(openstack stack show -c stack_status -f value $stack_name)" ]; do
        sleep 20
    done

    STATUS=$(openstack stack show -c stack_status -f value $stack_name)
    echo $STATUS
    if [ "CREATE_COMPLETE" != "$STATUS" ]; then
        echo "OpenSatck stack creation failed"
        FAILED='true'
        break;
    fi

    # wait till the Master node to become alive
    for i in $(seq 1 30); do
	sleep 30
        K8S_MST_IP=$(openstack stack output show $stack_name k8s_mst_vm_ip -c output_value -f value)
	timeout 1 ping -c 1 "$K8S_MST_IP" && break
    done

    timeout 1 ping -c 1 "$K8S_MST_IP" && break

    echo Error: OpenStack infrastructure issue: unable to reach master node "$K8S_MST_IP"
    FAILED='true'
    sleep 10
done

if ! timeout 1 ping -c 1 "$K8S_MST_IP"; then
    echo "Master node not reachable, stack creation failed, exit"
    exit 2
fi


K8S_MASTER_HOSTNAME="${stack_name}-k8s-mst"
echo "$K8S_MASTER_HOSTNAME $K8S_MST_IP" > ./ips-${stack_name}
while ! nc -z $K8S_MST_IP  29999; do
  echo "Wait for Master node $K8S_MST_IP to be ready"
  sleep 5
done

set +e

unset JOINCMD
while [[ -z $JOINCMD ]]; do
  sleep 15
  JOINCMD=$(ssh -i $SSH_KEY ubuntu@$K8S_MST_IP  -q -o "StrictHostKeyChecking no" sudo kubeadm token create --print-join-command)
done

for i in $(seq 1 99); do
  IP_NAME=k8s_$(printf "%02d" "$i")_vm_ip
  K8S_MINION_IP=$(openstack stack output show $stack_name $IP_NAME -c output_value -f value)
  if [ -z $K8S_MINION_IP ]; then
    break
  fi
  K8S_MINION_HOSTNAME=${stack_name}-k8s-$(printf "%02d" "$i")
  echo "$K8S_MINION_HOSTNAME $K8S_MINION_IP" >> ./ips-${stack_name}

  #while ! nc -z $K8S_MINION_IP  29999; do
  #  echo "Wait for minion node $K8S_MINION_IP to be ready"
  #  sleep 5
  #done
  echo "Joining $K8S_MINION_HOSTNAME [$K8S_MINION_IP] to cluster master $K8S_MST_IP with command $JOINCMD"
  while ! ssh -i $SSH_KEY -q -o "StrictHostKeyChecking no" ubuntu@$K8S_MINION_IP sudo $JOINCMD; do
    echo "Retry join command in 10 seconds"
    sleep 10
  done
done

export __IPS_${stack_name}__="$(cat ${WORKDIR}/ips-${stack_name})"
