################################################################################
#   Copyright (c)  2020 AT&T                                                   #
#                                                                              #
#   Licensed under the Creative Commons License, Attribution 4.0 Intl. (the    #
#   "License"); you may not use this file except in compliance with the        #
#   License.  You may obtain a copy of the License at                          #
#                                                                              #
#   https://creativecommons.org/licenses/by/4.0/                               #
#                                                                              #
#   Unless required by applicable law or agreed to in writing, documentation   #
#   distributed under the Documentation License is distributed on an "AS IS"   #
#   BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or     #
#   implied. See the Documentation License for the specific language governing #
#   permissions and limitations under the Documentation License.               #
#                                                                              #
################################################################################ 


This directory contains a set of scripts used in the Bronze Release "Getting
Started" series of demonstrations.  The video recordings of these demonstrations
are available at https://wiki.o-ran-sc.org/display/GS/Getting+Started.

To run these demonstration scripts, it is assumed that two Kubernetes clusters 
have been set up, and the SMO and (Near Realtime) RIC have been deployed into 
these two clusters following the instructions at 
https://wiki.o-ran-sc.org/display/GS/SMO+Installation and 
https://wiki.o-ran-sc.org/display/GS/Near+Realtime+RIC+Installation respectively.


__config-ip.sh
	This script configures the IP addresses of the RIC and SMO clusters into the
	Helm charts and scripts in the cloned it/dep repository.  Prior to the running
	of this script, the IP addresses of the SMO and RIC clusters can be configured 
	as environment variables, or the script will prompt the user to input them.  
	This script must be run in both the RIC and SMO clusters before starting any 
	of the demonstrations.

xapp-hw.sh, xapp-ts.sh
	These two scripts demonstrate the Hello World and the Traffic Steering xApps
	respectively.  They are to be run in a shell with sufficient privilege (e.g. 
	kubectl) to operate the RIC cluster.

a1-ric.sh, a1-smo.sh
	These two scripts demonstrate the A1 Bronze use case.  The *-ric.sh script is to
	be run in the RIC cluster and the *-smo.sh script is to be run in the SMO cluster.
	The scripts are interactive and will prompt the user to perform actions in sequence
	in these two clusters.

odu-high.sh
	The odu-high.sh script is to be run in a server outside of the (Near Realtime) RIC
	cluster.  It completes the steps of cloning, compiling, and running the O-DU High 
	to interact with the (Near Realtime) RIC to complete the E2 Setup handshake.


o1-ric.sh, o1-smo.sh, test-raise-alarm.sh
	These three scripts demonstrate the O1 Bronze use case.  The *-ric.sh script is to
        be run in the RIC cluster and the *-smo.sh script is to be run in the SMO cluster.
        The scripts are interactive and will prompt the user to perform actions in sequence 
        in these two clusters.  The test-raise-alarm.sh script shows how to raise artificial
	alarms in the RIC cluster.
