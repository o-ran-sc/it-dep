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

stack_name="ric"
full_deletion=false

#WORKSPACE=`/home/ubuntu/deploy-oom-onap/integration-master/integration`
#echo $WORKSPACE

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`pwd`
fi


openstack --version > /dev/null
if [ $? -eq 0 ]; then
    echo OK
else
    echo "Must run in an envirnment with openstack cli"
    exit 1
fi

if [ -z "$OS_USERNAME" ]; then
    echo "Must source the Openstack RC file for the target installation tenant"
    exit 1
fi


usage() {
    echo "Usage: $0 [ -s <stack name> ]" 1>&2;

    echo "s:    Set the name to be used for stack. This name will be used for naming of resources" 1>&2;
    exit 1;
}


while getopts ":n:s:m:rq6" o; do
    case "${o}" in
        s)
            if [[ ! ${OPTARG} =~ ^[0-9]+$ ]];then
                stack_name=${OPTARG}
            else
                usage
            fi
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ "$#" -gt 0 ]; then
   usage
fi


openstack stack delete $stack_name 

exit 0
