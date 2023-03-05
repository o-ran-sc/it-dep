# Copyright 2023 Samsung Electronics Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/env bash

sudo apt-get --allow-unauthenticated update
yes | sudo  NEEDRESTART_SUSPEND=1  DEBIAN_FRONTEND=noninteractive apt-get -qq install python3-venv python3-pip -y

python3 -m venv venv
venv/bin/pip3 install ansible
venv/bin/pip3 install jmespath
venv/bin/ansible-galaxy collection install community.general
venv/bin/ansible-galaxy collection install kubernetes.core

cd /home/ubuntu/oran_smo
../venv/bin/ansible-playbook -e ansible_connection=local -e ansible_user=ubuntu -e os_user=ubuntu -e os_group=ubuntu deploy_mk8s.yaml
../venv/bin/ansible-playbook -e ansible_connection=local -e ansible_user=ubuntu -e os_user=ubuntu -e os_group=ubuntu deploy_oran_smo.yaml
