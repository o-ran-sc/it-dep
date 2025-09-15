SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.NOTPARALLEL:

SCRIPTS_DIR := scripts
SUDO ?=                  
KUBECONFIG ?= $(HOME)/.kube/config
export KUBECONFIG         

.PHONY: help k8s storage chartmuseum all run

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' Makefile | \
	awk 'BEGIN {FS=":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'

k8s: ## Install k8s with CNI (requires IP=...)
	@test -n "$(IP)" || { echo "Error: IP is required. Usage: make k8s IP=192.168.8.10"; exit 1; }
	@$(SUDO) bash "$(SCRIPTS_DIR)/setup_k8s.sh" --ip-address "$(IP)" \
	  || { code=$$?; echo "k8s failed (setup_k8s.sh exit $$code)"; exit $$code; }
	@echo "<== k8s: done"

storage: ## Install local storage class (OpenEBS)
	@echo "==> storage: using KUBECONFIG=$(KUBECONFIG)"
	@env KUBECONFIG="$(KUBECONFIG)" HOME="$(HOME)" \
	  bash "$(SCRIPTS_DIR)/openebs.sh" \
	  || { code=$$?; echo "storage failed (openebs.sh exit $$code)"; exit $$code; }
	@echo "<== storage: done"

chartmuseum: ## Install ChartMuseum
	@echo "==> chartmuseum: using KUBECONFIG=$(KUBECONFIG)"
	@env KUBECONFIG="$(KUBECONFIG)" HOME="$(HOME)" \
	  bash "$(SCRIPTS_DIR)/chartmuseum.sh" \
	  || { code=$$?; echo "chartmuseum failed (chartmuseum.sh exit $$code)"; exit $$code; }
	@echo "<== chartmuseum: done"

all: k8s storage chartmuseum 
run: all 