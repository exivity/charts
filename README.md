# Exivity Helm Chart

[Exivity Installation Guide](https://docs.exivity.com/getting%20started/installation/kubernetes/)

## Overview

This Helm chart deploys Exivity, a comprehensive cloud metering and billing solution, on Kubernetes clusters.

## Prerequisites

### NFS Setup

To use NFS as a storage solution for Exivity, install the NFS server provisioner using Helm:

```bash
helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
helm install nfs-server nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner \
    --namespace nfs-server \
    --create-namespace \
    --wait \
    --set persistence.enabled=true \
    --set persistence.size=5Gi \
    --set storageClass.name=nfs-client \
    --set storageClass.allowVolumeExpansion=true \
    --set 'storageClass.mountOptions[0]=nfsvers=4.2' \
    --set 'storageClass.mountOptions[1]=rsize=4096' \
    --set 'storageClass.mountOptions[2]=wsize=4096' \
    --set 'storageClass.mountOptions[3]=hard' \
    --set 'storageClass.mountOptions[4]=retrans=3' \
    --set 'storageClass.mountOptions[5]=proto=tcp' \
    --set 'storageClass.mountOptions[6]=noatime' \
    --set 'storageClass.mountOptions[7]=nodiratime'
```

## Installation

### Add Helm Repository

To add the Exivity Helm repository:

```bash
helm repo add exivity https://charts.exivity.com
```

### Install the Chart

To install the chart with the release name `exivity` in the `exivity` namespace, using the previously set up NFS storage class:

```bash
helm upgrade --install exivity ./charts/exivity \
    --namespace exivity \
    --create-namespace \
    --wait \
    --timeout $(HELM_TIMEOUT) \
    --set storage.storageClass=nfs-client
```
