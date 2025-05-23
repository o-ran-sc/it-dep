# Copyright © 2017 Amdocs, Bell Canada
# Copyright (C) 2024 OpenInfra Foundation Europe. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PARENT_CHART := nonrtric
COMMON_CHARTS_DIR := nonrtric-common aux-common ric-common
# FIXME OOM-765
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OUTPUT_DIR := $(ROOT_DIR)/dist
PACKAGE_DIR := $(OUTPUT_DIR)/packages
SECRET_DIR := $(OUTPUT_DIR)/secrets
HELM_BIN := helm

# Helm v2 and helm v3 uses different version format so we first try in helm v3 format
# and if it fails then we fallback to helm v2 one
HELM_VER := $(shell $(HELM_BIN) version --template "{{.Version}}" 2>/dev/null)
ifneq "$(findstring v3,$(HELM_VER))" "v3"
	HELM_VER := $(shell $(HELM_BIN) version -c --template "{{.Client.SemVer}}")
endif

# use this if you would like to cm-push onap charts to repo with other name
# WARNING: Helm v3+ only
# WARNING: Make sure to edit also requirements files
HELM_REPO := local

ifneq ($(SKIP_LINT),TRUE)
	HELM_LINT_CMD := $(HELM_BIN) lint
else
	HELM_LINT_CMD := echo "Skipping linting of"
endif

#SUBMODS := robot
#EXCLUDES := config oneclick readiness test dist helm $(PARENT_CHART) dcae $(SUBMODS)
EXCLUDES := config oneclick readiness test dist helm policy-clamp-ac-dme-ppnt smo $(PARENT_CHART)
HELM_CHARTS := $(filter-out $(EXCLUDES), $(sort $(patsubst %/.,%,$(wildcard */.)))) $(PARENT_CHART)

.PHONY: $(EXCLUDES) $(HELM_CHARTS) check-for-staging-images

all: print_helm_bin $(COMMON_CHARTS_DIR) $(SUBMODS) $(HELM_CHARTS) helm-repo-update

$(COMMON_CHARTS):
	@echo "\n[$@]"
	@make package-$@

$(HELM_CHARTS):
	@echo "\n[$@]"
	@make package-$@

$(SUBMODS):
	@echo "\n[$@]"
	@make submod-$@
	@make package-$@

submod-%:
	@make $*/Chart.yaml

%/Chart.yaml:
	$(error Submodule $* needs to be retrieved from gerrit.  See https://wiki.onap.org/display/DW/OOM+-+Development+workflow+after+code+transfer+to+tech+teams ); fi

print_helm_bin:
	$(info Using Helm binary ${HELM_BIN} which is helm version ${HELM_VER})

make-%:
	@if [ -f $*/Makefile ]; then make -C $*; fi

dep-%: make-%
	@if [ -f $*/Chart.yaml ]; then $(HELM_BIN) dep up $*; fi

lint-%: dep-%
	@if [ -f $*/Chart.yaml ]; then $(HELM_LINT_CMD) $*; fi

package-%: lint-%
	@mkdir -p $(PACKAGE_DIR)
ifeq "$(findstring v3,$(HELM_VER))" "v3"
	@if [ -f $*/Chart.yaml ]; then PACKAGE_NAME=$$($(HELM_BIN) package -d $(PACKAGE_DIR) $* | cut -d":" -f2) && $(HELM_BIN) cm-push -f $$PACKAGE_NAME $(HELM_REPO); fi
else
	@if [ -f $*/Chart.yaml ]; then $(HELM_BIN) package -d $(PACKAGE_DIR) $*; fi
	@$(HELM_BIN) repo index $(PACKAGE_DIR)
endif

clean:
	@rm -f */Chart.lock
	@find . -type f -name '*.tgz' -delete
	@rm -rf $(PACKAGE_DIR)/*

# publish helm plugins via distrubtion directory
plugins:
	@cp -R helm $(PACKAGE_DIR)/

# start up a local helm repo to serve up helm chart packages
# WARNING: Only helm < v3 supported
repo:
	@mkdir -p $(PACKAGE_DIR)
	@$(HELM_BIN) serve --repo-path $(PACKAGE_DIR) &
	@sleep 3
	@$(HELM_BIN) repo index $(PACKAGE_DIR)
	@$(HELM_BIN) repo add local http://127.0.0.1:8879

# stop local helm repo
# WARNING: Only helm < v3 supported
repo-stop:
	@pkill $(HELM_BIN)
	@$(HELM_BIN) repo remove local

check-for-staging-images:
	$(ROOT_DIR)/contrib/tools/check-for-staging-images.sh

helm-repo-update:
ifeq "$(findstring v3,$(HELM_VER))" "v3"
	@$(HELM_BIN) repo update
endif

%:
	@:
