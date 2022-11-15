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
"""Onap SO module."""
from onapsdk.so.so_element import SoElement

class OranSo(SoElement):
    """So class."""

    def healthcheck(self) -> dict:
        """
        Healthcheck SO main component.

        Returns:
           the status of SO components
        """
        status = self.send_message_json('GET',
                                        'Get status of SO components',
                                        f"{self.base_url}/manage/health",
                                        headers=self.headers)
        return status
