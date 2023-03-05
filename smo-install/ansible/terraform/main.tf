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


provider "aws" {
  region = var.region
}

resource "aws_instance" "oran_smo" {
  ami           = var.ami
  instance_type = var.instance
  key_name      = "oran_smo"

  vpc_security_group_ids = [
    "${aws_security_group.web.id}",
    "${aws_security_group.ssh.id}"
  ]
  root_block_device {
    volume_size = 300
    volume_type = "gp2"
    encrypted   = false
  }
  connection {
    host = "${self.public_ip}"
    private_key = "${file(var.private_key)}"
    user        = "${var.ansible_user}"
    agent       = false
  }

  provisioner "file" {
    source      = "../oran_smo"
    destination = "/home/ubuntu/oran_smo"
  }

  provisioner "remote-exec" {
    inline = [ 
               "chmod +x oran_smo/aws_run.sh",
               "oran_smo/aws_run.sh"
              ]
  }

  tags = {
    Name = "oran-ec2"
  }
}

resource "aws_security_group" "web" {
  name        = "kiali-sg"
  description = "kiali-sg"

  ingress {
    from_port   = 20001
    to_port     = 20001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 20002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_security_group" "ssh" {
  name        = "default-ssh"
  description = "SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


}

