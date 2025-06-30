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

## LDAP over TLS

Exivity supports secure LDAP connectivity using TLS certificates. This feature allows you to configure LDAP authentication with certificate-based validation, ensuring secure communication between Exivity and your LDAP server.

### Configuration

To enable LDAP over TLS, configure the following values:

```yaml
ldap:
  # PEM certificate content for LDAP TLS validation
  # Provide the complete PEM certificate content as a multiline string
  # Supports Helm templating functions for dynamic content
  tlsCacert: |
    -----BEGIN CERTIFICATE-----
    MIIDXTCCAkWgAwIBAgIJAKoK/OvD7vn1MA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
    BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
    ...
    -----END CERTIFICATE-----
  
  # Path where the certificate will be mounted (default: /etc/ssl/certs/ldap.pem)
  # Also supports Helm templating functions
  tlsCacertPath: "/etc/ssl/certs/ldap.pem"
```

**Important:** Both `tlsCacert` and `tlsCacertPath` must be provided together. The chart will fail validation if only one is configured.

### Installation with LDAP TLS

```bash
helm upgrade --install exivity ./charts/exivity \
    --namespace exivity \
    --create-namespace \
    --set-file ldap.tlsCacert=path/to/your/ldap-ca.pem \
    --set ldap.tlsCacertPath=/etc/ssl/certs/ldap.pem
```

### Using values.yaml

Create a `values.yaml` file with your LDAP certificate:

```yaml
ldap:
  tlsCacert: |
    -----BEGIN CERTIFICATE-----
    # Your LDAP CA certificate content here
    -----END CERTIFICATE-----
  tlsCacertPath: "/etc/ssl/certs/ldap.pem"
```

Then install:

```bash
helm upgrade --install exivity ./charts/exivity \
    --namespace exivity \
    --create-namespace \
    --values values.yaml
```

### How it Works

When LDAP TLS is configured:

1. **Validation**: The chart validates that both certificate and path are provided together
2. **Secret Creation**: A Kubernetes Secret is created containing the PEM certificate
3. **Volume Mount**: The certificate is mounted into the Proximity API container at the specified path with secure permissions (0444)
4. **Environment Variable**: The `LDAPTLS_CACERT` environment variable is set to the certificate path
5. **Secure Connection**: PHP's LDAP functions will use this certificate for TLS validation

The implementation ensures backward compatibility - if no LDAP TLS configuration is provided, no additional resources are created.

### Security Notes

- Certificate files are mounted with read-only permissions (0444)
- The Secret is created only when `ldap.tlsCacert` is provided
- If no certificate is configured, LDAP connections will work without TLS validation
- The certificate is automatically available to all LDAP operations within the Proximity API

### Troubleshooting

**Chart fails with validation error:**
- Both `ldap.tlsCacert` and `ldap.tlsCacertPath` must be provided together
- If you provide a certificate, you must also specify a path
- If you provide a custom path, you must also provide a certificate
- Verify the PEM certificate format is correct (must start with `-----BEGIN CERTIFICATE-----`)

**LDAP connection issues:**
- Check that the certificate matches your LDAP server's CA
- Verify the certificate path is accessible within the container
- Review Proximity API logs for LDAP connection errors

### Validation Features

The chart includes robust validation to ensure secure LDAP TLS configuration:

- **Early Validation**: Chart deployment fails during `helm lint` or `helm template` if configuration is incomplete
- **Template Support**: Certificate content and paths support Helm templating functions
- **Backward Compatibility**: No changes required for existing deployments without LDAP TLS
- **Secure Defaults**: Certificate files are mounted with read-only permissions (0444)
- **Conditional Resources**: LDAP resources are only created when needed
