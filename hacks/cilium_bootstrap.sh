#!/usr/bin/env sh

helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium \
    --create-namespace \
    --namespace network \
    --version=1.9.0 \
    --set containerRuntime.integration="containerd" \
    --set containerRuntime.socketPath="/var/run/k3s/containerd/containerd.sock" \
    --set kubeProxyReplacement="strict"

