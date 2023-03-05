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

#variable "profile" {
#  default = "oran_smo"
#}

variable "region" {
  default = "us-east-1"
}

variable "instance" {
  default = "m6i.12xlarge"
}

variable "instance_count" {
  default = "1"
}

variable "private_key" {
  default = "~/.ssh/oran_smo.pem"
}

variable "ansible_user" {
  default = "ubuntu"
}

variable "ami" {
  default = "ami-08d4ac5b634553e16"
}
