#!/usr/bin/env bash
kubectl delete namespace onap
kubectl delete namespace nonrtric
kubectl delete namespace network
kubectl delete namespace tests
kubectl delete namespace strimzi-system
kubectl delete pv --all
sudo rm -rf /dockerdata-nfs
