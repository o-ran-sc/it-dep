#!/usr/bin/env bash

kubectl rollout restart deployments/onap-$1 -n onap
echo "--------------------------------------------------------------------------------------------------------"
kubectl rollout status deployments/onap-$1 -n onap
echo "--------------------------------------------------------------------------------------------------------"
