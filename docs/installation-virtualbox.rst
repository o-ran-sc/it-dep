.. This work is licensed under a Creative Commons Attribution 4.0 International License.
.. SPDX-License-Identifier: CC-BY-4.0
.. ===============LICENSE_START=======================================================
.. Copyright (C) 2019 AT&T Intellectual Property 
.. ===================================================================================
.. This documentation file is distributed under the Creative Commons Attribution 
.. 4.0 International License (the "License"); you may not use this file except in 
.. compliance with the License.  You may obtain a copy of the License at
..
.. http://creativecommons.org/licenses/by/4.0
..
.. This file is distributed on an "AS IS" BASIS,
.. WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
.. See the License for the specific language governing permissions and
.. limitations under the License.
.. ===============LICENSE_END=========================================================



Networking
----------
The set up requires two VMs connected by a private network.  With VirtualBox, this can be done by going under its "Preferences" menu and set up a private NAT network.

1. "Preference", then select the "Network" tab;
2. Clicking on the "+" icon to create a new NAT network.  A new entry will appear in the NAT networks list;
3. Double clicking on the new network to edit its details, including giving int a name such as "RICNetwork";
4. On the next page, make sure to check: "Enable Network", uncheck the "Supports DHCP" box, and make a note of the "Network CIDR" (for this example, it is 10.0.2.0/24);
5. Click on the "Port Forwarding" button to create the following rules:

  1. "ssh to ric", TCP, 127.0.0.1, 22222, 10.0.2.100, 22;
  2. "ssh to aux", TCP, 127.0.0.1, 22223, 10.0.2.101, 22;
  3. "entry to ric", TCP, 127.0.0.1, 22224, 10.0.2.100, 32080;
  4. "entry to aux", TCP, 127.0.0.1, 22225, 10.0.2.101, 32080.

6. "Ok" all the way back to create the network.


Creating VMs
-------------

Create a VirtualBox VM:

1. "New", then enter the following in the pop-up: Name it for example **myric**, of "Linux" type, and at least 4G RAM and 10G disk;
2. "Create" to create the VM.  It will appear in the list of VMs.
3. Highlight the new VM entry, right click on it, select "Settings".

  1. Under the "System" tab, then "Processor" tab, make sure to give the VM at least 2 vCPUs.
  2. Under the "Storage" tab, point the CD to a Ubuntu 18.04 server ISO file;
  3. Under the "Network" tab, then "Adapter 1" tab, make sure to:

    1. Check "Enable Network Adapter";
    2. Attached to "NAT Network";
    3. Network name for what was created in the previous section: "RICNetwork".

Repeat the process and create the second VM named **myaux**.


Booting VM and OS Installation
------------------------------

Follow the OS installation steps to install OS to the VM virtual disk media.  Make sure to install openssh server.  


VM Network Configuration
-------------------------

Depending on the version of the OS, the networking may be configured during the OS installation or after.  The network interface is configured with static IP address:

- IP Address:  10.0.2.100 for myric or 10.0.2.101 for myaux;
- Network: 10.0.2.10/24, or network mask 255.255.255.0
- Default gateway: 10.0.2.1
- Name server: 8.8.8.8


Accessing the VMs 
-----------------

Because of the port forwarding configurations, the VMs are accessible from the VirtualBox host via ssh. 

- To access **myric**:  ssh {{USERNAME}}@127.0.0.1 -p 22222
- To access **myaux**:  ssh {{USERNAME}}@127.0.0.1 -p 22223


