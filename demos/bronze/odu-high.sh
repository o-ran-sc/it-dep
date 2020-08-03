#!/bin/bash
################################################################################
#   Copyright (c) 2020 AT&T Intellectual Property.                             #
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

acknowledge() {
  echo "$1"
  read  -n 1 -p "Press any key to continue, or CTRL-C to abort" mainmenuinput
  echo
}


acknowledge "Make sure the env veriables __RIC_HOST__ and __ODU_HOST__ are populated with the hostname/IP address of the RIC cluster and ODU server."
if [[ -z "$__RIC_HOST__" ]] || [[ -z "$__ODU_HOST__" ]]; then
  echo 'Cannot proceed, must have the Hostname/IP of the RIC and ODU as env variables $__RIC_HOST__ and $__ODU_HOST__'
  echo 'Use the address of the local NIC that the ODU binds for SCTP communication for $__ODU_HOST__'
  exit
fi

acknowledge "O-DU HIGH code needs to be recompiled with the RIC and ODU server addresses."
apt-get install libpcap-dev gcc-multilib g++-multilib libsctp-dev
git clone http://gerrit.o-ran-sc.org/r/o-du/l2
cd l2
# Edit src/du_app/du_cfg.h for the IP addresses, both ODU and RIC (because ODU binds
# to specific local port for SCTP, it needs the ODU IP address as well to decide which 
# interface to bind.  use ifconfig to identify.)
sed -i "s/^#define RIC_IP_V4_ADDR.*/#define RIC_IP_V4_ADDR \"${__RIC_HOST__}\"/g" src/du_app/du_cfg.h 
sed -i "s/^#define DU_IP_V4_ADDR.*/#define DU_IP_V4_ADDR \"${__ODU_HOST__}\"/g" src/du_app/du_cfg.h 
# RIC Bronze E2T's SCTP is at 36422, but exposed as nodeport on 36422
sed -i "s/^#define RIC_PORT.*/#define RIC_PORT 32222/g" src/du_app/du_cfg.h 

cd build/odu/
make clean_odu odu MACHINE=BIT64 MODE=FDD

acknowledge "The compilation has completed.  The next step is to run the O-DU HIGH executable.  We will see the ODU HIGH establishes SCTP connection to E2Termination, then sending E2 Setup Request and receiving E2 Setup Response.  It will be good to also start following the logs of the E2 Termination."
cd ../../bin/odu
./odu
# we should see odu dumps communication parameters

