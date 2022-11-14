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

"""Network Slicing Simulators module."""
import logging
import logging.config
from subprocess import check_output, run
from onapsdk.configuration import settings
from waiting import wait

logging.config.dictConfig(settings.LOG_CONFIG)
logger = logging.getLogger("Network Slicing Simulators k8s")

class NsSimulators():
    """Network Slicing simulators controls the simulators k8s deployment."""

    @staticmethod
    def start_ns_simulators():
        """Start all simulators."""
        logger.info("Start the network slicing simulators")
        cmd = "kubectl create namespace nssimulators"
        check_output(cmd, shell=True).decode('utf-8')
        cmd = f"helm install --debug ns-simulators local/ns-simulators --namespace nssimulators"
        check_output(cmd, shell=True).decode('utf-8')

    def start_and_wait_ns_simulators(self):
        """Start and wait for all simulators."""
        logger.info("Start the network slicing simulators")
        self.start_ns_simulators()
        NsSimulators.wait_for_ns_simulators_to_be_running()

    def stop_and_wait_ns_simulators(self):
        """Stop and wait for all simulators."""
        logger.info("Stop the network slicing simulators")
        self.stop_ns_simulators()
        NsSimulators.wait_for_ns_simulators_to_be_stopped()

    @staticmethod
    def stop_ns_simulators():
        """Stop the simulators."""
        logger.info("Clean up any network slicing simulators")
        cmd = "kubectl delete namespace nssimulators"
        run(cmd, shell=True, check=False)

    @staticmethod
    def is_ns_simulators_up() -> bool:
        """Check if the network slicing simulators are up."""
        cmd = "kubectl get pods --field-selector status.phase!=Running -n nssimulators"
        result = check_output(cmd, shell=True).decode('utf-8')
        logger.info("Checking if network slicing simulators is UP: %s", result)
        if result == '':
            logger.info("Network slicing sims is Up")
            return True
        logger.info("Network slicing sims is Down")
        return False


    @staticmethod
    def wait_for_ns_simulators_to_be_running():
        """Check and wait for the network slicing sims to be running."""
        wait(lambda: NsSimulators.is_ns_simulators_up(), sleep_seconds=settings.NETWORK_SIMULATOR_CHECK_RETRY, timeout_seconds=settings.NETWORK_SIMULATOR_CHECK_TIMEOUT, waiting_for="Network slicing simulators to be ready")

    @staticmethod
    def is_ns_simulators_stopped() -> bool:
        """Check if the network slicing simulators are stopped."""
        cmd = "kubectl get ns | grep nssimulators | wc -l"
        result = check_output(cmd, shell=True).decode('utf-8')
        logger.info("Checking if network slicing simulators is stopped: %s", result)
        if int(result) == 0:
            logger.info("Network slicing sims are Down")
            return True
        logger.info("Network slicing sims is still Up")
        return False

    @staticmethod
    def wait_for_ns_simulators_to_be_stopped():
        """Check and wait for the network slicing sims to be stopped."""
        wait(lambda: NsSimulators.is_ns_simulators_stopped(), sleep_seconds=settings.NETWORK_SIMULATOR_CHECK_RETRY, timeout_seconds=settings.NETWORK_SIMULATOR_CHECK_TIMEOUT, waiting_for="Network slicing simulators to be ready")
