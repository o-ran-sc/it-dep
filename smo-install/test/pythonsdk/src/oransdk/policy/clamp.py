#!/usr/bin/env python3
###
# ============LICENSE_START=======================================================
# ORAN SMO PACKAGE - PYTHONSDK TESTS
# ================================================================================
# Copyright (C) 2022 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
#
###
"""Onap Policy Clamp Tosca Template module."""

from typing import Dict
from onapsdk.clamp.clamp_element import Clamp

class ClampToscaTemplate(Clamp):
    """Onap Policy Clamp Tosca Template class."""

    header = {"Accept": "application/json", "Content-Type": "application/json"}

    def __init__(self, basic_auth: Dict[str, str]) -> None:
        """
        Initialize loop instance object.

        Args:
            basic_auth : basic auth

        """
        super().__init__()
        self.basic_auth = basic_auth

    def get_template_instance(self) -> dict:
        """
        Get tosca template instance.

        Returns:
            the tosca template instance
        """
        url = f"{self.base_url()}/toscaControlLoop/getToscaInstantiation"
        template_instance = self.send_message_json('GET',
                                                   'Get tosca template instance',
                                                   url,
                                                   basic_auth=self.basic_auth)

        return template_instance

    def upload_commission(self, tosca_template) -> dict:
        """
        Upload Tosca to commissioning.

        Args:
            tosca_template: the tosca template yaml
        Returns:
            the response of the uploading action

        """
        url = f"{self.base_url()}/toscaControlLoop/commissionToscaTemplate"
        response = self.send_message_json('POST',
                                          'Upload Tosca to commissioning',
                                          url,
                                          data=tosca_template,
                                          headers=self.header,
                                          basic_auth=self.basic_auth)
        return response

    def create_instance(self, tosca_instance_properties) -> dict:
        """
        Create Tosca instance.

        Args:
            tosca_instance_properties (str): the tosca template properties
        Returns:
            the response of the creation action
        """
        url = f"{self.base_url()}/toscaControlLoop/postToscaInstanceProperties"
        response = self.send_message_json('POST',
                                          'Create Tosca instance',
                                          url,
                                          data=tosca_instance_properties,
                                          headers=self.header,
                                          basic_auth=self.basic_auth)
        return response

    def get_template_instance_status(self, name, version) -> dict:
        """
        Get tosca template instance status.

        Args:
            name (str): the name of the template instance
            version (str): the version of the template instance
        Returns:
            the template instance
        """
        url = f"{self.base_url()}/toscaControlLoop/getInstantiationOrderState?name={name}&version={version}"
        template_instance = self.send_message_json('GET',
                                                   'Get tosca template instance',
                                                   url,
                                                   basic_auth=self.basic_auth)

        return template_instance

    def change_instance_status(self, new_status, name, version) -> dict:
        """
        Update tosca instance status.

        Args:
            new_status (str): the new instance status
            name (str): the new instance name
            version (str): the new instance version
        Returns:
            the updated template instance
        """
        body = '{"orderedState":"' + new_status + '","controlLoopIdentifierList":[{"name":"' + name + '","version":"' + version + '"}]}'
        url = f"{self.base_url()}/toscaControlLoop/putToscaInstantiationStateChange"
        response = self.send_message_json('PUT',
                                          'Update tosca instance status',
                                          url,
                                          data=body,
                                          headers=self.header,
                                          basic_auth=self.basic_auth)
        return response

    def delete_template_instance(self, name: str, version: str) -> dict:
        """
        Delete the tosca instance.

        Args:
            name (str): the instance name.
            version (str): the instance version.
        Returns:
            the response of the deletion action
        """
        url = f"{self.base_url()}/toscaControlLoop/deleteToscaInstanceProperties?name={name}&version={version}"
        response = self.send_message_json('DELETE',
                                          'Delete the tosca instance',
                                          url,
                                          headers=self.header,
                                          basic_auth=self.basic_auth)
        return response

    def decommission_template(self, name: str, version: str) -> dict:
        """
        Decommission the tosca template.

        Args:
            name (str): the tosca template name.
            version (str): the tosca template version.
        Returns:
            the response of the decommission action
        """
        url = f"{self.base_url()}/toscaControlLoop/decommissionToscaTemplate?name={name}&version={version}"
        response = self.send_message_json('DELETE',
                                          'Decommission the tosca template',
                                          url,
                                          headers=self.header,
                                          basic_auth=self.basic_auth)
        return response
