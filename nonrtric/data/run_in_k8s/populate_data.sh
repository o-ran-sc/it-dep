#!/bin/bash

#  ============LICENSE_START===============================================
#  Copyright (C) 2020 Nordix Foundation. All rights reserved.
#  ========================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  ============LICENSE_END=================================================
#

# The scripts in data/ will generate some dummy data in the running system.
# It will create:
# one policy type in a1-sim-OSC_0
# one service in policy agent
# five policies in a1-sim-OSC_0
# one policy in a1-sim-STD_0

policy_agent_host="policymanagementservice"
policy_agent_port="9080"
a1_sim_osc_0_host="a1-sim-osc-0.a1-sim"
a1_sim_osc_0_port="8085"
a1_sim_osc_1_host="a1-sim-osc-1.a1-sim"
a1_sim_osc_1_port="8085"
a1_sim_std_0_host="a1-sim-std-0.a1-sim"
a1_sim_std_0_port="8085"
a1_sim_std_1_host="a1-sim-std-1.a1-sim"
a1_sim_std_1_port="8085"
httpx=http

echo "policy agent status:"
curl -skw " %{http_code}" $httpx://$policy_agent_host:$policy_agent_port/status
echo -e "\n"

echo "ric1 version:"
curl -skw " %{http_code}" $httpx://$a1_sim_osc_0_host:$a1_sim_osc_0_port/counter/interface
echo -e "\n"

echo "ric2 version:"
curl -skw " %{http_code}" $httpx://$a1_sim_osc_1_host:$a1_sim_osc_1_port/counter/interface
echo -e "\n"

echo "ric3 version:"
curl -skw " %{http_code}" $httpx://$a1_sim_std_0_host:$a1_sim_std_0_port/counter/interface
echo -e "\n"

echo "ric4 version:"
curl -skw " %{http_code}" $httpx://$a1_sim_std_1_host:$a1_sim_std_1_port/counter/interface
echo -e "\n"

echo "create policy type 1 to ric1:"
curl -X PUT -skw " %{http_code}" $httpx://$a1_sim_osc_0_host:$a1_sim_osc_0_port/policytype?id=1 -H Content-Type:application/json --data-binary @testdata/OSC/policy_type.json
echo -e "\n"

echo "create policy type 1 to ric2:"
curl -X PUT -skw " %{http_code}" $httpx://$a1_sim_osc_1_host:$a1_sim_osc_1_port/policytype?id=1 -H Content-Type:application/json --data-binary @testdata/OSC/policy_type.json
echo -e "\n"

for i in {1..12}; do
	echo "policy types from policy agent:"
    curlString="curl -skw %{http_code} $httpx://$policy_agent_host:$policy_agent_port/policy_types"
    res=$($curlString)
    echo "$res"
    expect="[\"\",\"1\"]200"
    if [ "$res" == "$expect" ]; then
        echo -e "\n"
        break;
    else
        sleep $i
    fi
done

echo "create service 1 to policy agent:"
curl -k -X PUT -sw " %{http_code}" -H accept:application/json -H Content-Type:application/json "$httpx://$policy_agent_host:$policy_agent_port/service" --data-binary @testdata/service.json
echo -e "\n"

echo "create policy 2000 to ric1 with type1 and service1 via policy agent:"
curl -k -X PUT -sw " %{http_code}" -H accept:application/json -H Content-Type:application/json "$httpx://$policy_agent_host:$policy_agent_port/policy?id=2000&ric=ric1&service=service1&type=1" --data-binary @testdata/policy.json
echo -e "\n"

echo "create policy 2001 to ric1 with type1 and service1 via policy agent:"
curl -k -X PUT -sw " %{http_code}" -H accept:application/json -H Content-Type:application/json "$httpx://$policy_agent_host:$policy_agent_port/policy?id=2001&ric=ric1&service=service1&type=1" --data '{"scope": {"ueId": "ue3100","qosId": "qos3100"},"qosObjective": {"priorityLevel": 3101}}'
echo -e "\n"

echo "create policy 2002 to ric1 with type1 and service1 via policy agent:"
curl -k -X PUT -sw " %{http_code}" -H accept:application/json -H Content-Type:application/json "$httpx://$policy_agent_host:$policy_agent_port/policy?id=2002&ric=ric1&service=service1&type=1" --data '{"scope": {"ueId": "ue3100","qosId": "qos3100"},"qosObjective": {"priorityLevel": 3102}}'
echo -e "\n"

echo "create policy 2003 to ric1 with type1 and service1 via policy agent:"
curl -k -X PUT -sw " %{http_code}" -H accept:application/json -H Content-Type:application/json "$httpx://$policy_agent_host:$policy_agent_port/policy?id=2003&ric=ric1&service=service1&type=1" --data '{"scope": {"ueId": "ue3100","qosId": "qos3100"},"qosObjective": {"priorityLevel": 3103}}'
echo -e "\n"

echo "create policy 2004 to ric1 with type1 and service1 via policy agent:"
curl -k -X PUT -sw " %{http_code}" -H accept:application/json -H Content-Type:application/json "$httpx://$policy_agent_host:$policy_agent_port/policy?id=2004&ric=ric1&service=service1&type=1" --data '{"scope": {"ueId": "ue3100","qosId": "qos3100"},"qosObjective": {"priorityLevel": 3104}}'
echo -e "\n"

echo "policy numbers from ric1:"
curl -skw " %{http_code}" $httpx://$a1_sim_osc_0_host:$a1_sim_osc_0_port/counter/num_instances
echo -e "\n"

echo "create policy 2100 to ric3 with service1 via policy agent, no type:"
curl -k -X PUT -sw " %{http_code}" -H accept:application/json -H Content-Type:application/json "$httpx://$policy_agent_host:$policy_agent_port/policy?id=2100&ric=ric3&service=service1" --data-binary @testdata/policy.json
echo -e "\n"

echo "policy numbers from ric3:"
curl -skw " %{http_code}" $httpx://$a1_sim_std_0_host:$a1_sim_std_0_port/counter/num_instances
echo -e "\n"

echo "policy id 2000 from policy agent:"
curl -k -X GET -sw " %{http_code}" $httpx://$policy_agent_host:$policy_agent_port/policy?id=2000
echo -e "\n"

echo "policy id 2100 from policy agent:"
curl -k -X GET -sw " %{http_code}" $httpx://$policy_agent_host:$policy_agent_port/policy?id=2100
echo -e "\n"