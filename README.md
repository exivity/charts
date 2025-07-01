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

**Important:** To enable LDAP TLS, provide the `tlsCacert` value. The `tlsCacertPath` has a secure default and can be customized if needed.

### Installation with LDAP TLS

**Option 1: Using --set-file (certificate from file):**
```bash
helm upgrade --install exivity ./charts/exivity \
    --namespace exivity \
    --create-namespace \
    --set-file ldap.tlsCacert=path/to/your/ldap-ca.pem
```

**Option 2: Using values.yaml file (recommended for complex certificates):**
```bash
helm upgrade --install exivity ./charts/exivity \
    --namespace exivity \
    --create-namespace \
    --values values.yaml
```

### Using values.yaml

Create a `values.yaml` file with your LDAP certificate:

```yaml
ldap:
  tlsCacert: |
    -----BEGIN CERTIFICATE-----
    # Your LDAP CA certificate content here
    -----END CERTIFICATE-----
  # tlsCacertPath: "/etc/ssl/certs/ldap.pem"  # Optional: uses secure default
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

1. **Conditional Activation**: LDAP TLS features are enabled when `ldap.tlsCacert` is provided
2. **Secret Creation**: A Kubernetes Secret is created containing the PEM certificate
3. **Volume Mount**: The certificate is mounted into the Proximity API container at the specified path with secure permissions (0444)
4. **Environment Variable**: The `LDAPTLS_CACERT` environment variable is set to the certificate path
5. **Secure Connection**: PHP's LDAP functions will use this certificate for TLS validation

The implementation ensures backward compatibility - if no LDAP TLS configuration is provided, no additional resources are created.

### Security Notes

- Certificate files are mounted with read-only permissions (0444)
- The Secret is created only when `ldap.tlsCacert` is provided
- The `tlsCacertPath` has a secure default (`/etc/ssl/certs/ldap.pem`) that works for most scenarios

### Troubleshooting

**LDAP TLS not working:**
- Ensure `ldap.tlsCacert` contains a valid PEM certificate
- Verify the PEM certificate format is correct (must start with `-----BEGIN CERTIFICATE-----`)
- Check that the certificate matches your LDAP server's CA
- The default certificate path (`/etc/ssl/certs/ldap.pem`) works for most scenarios

**LDAP connection issues:**
- Check that the certificate matches your LDAP server's CA
- Verify the certificate path is accessible within the container
- Review Proximity API logs for LDAP connection errors
- Ensure your LDAP server supports TLS connections

### Implementation Features

The chart includes robust configuration to ensure secure LDAP TLS implementation:

- **Conditional Activation**: LDAP TLS resources are only created when `ldap.tlsCacert` is provided
- **Backward Compatibility**: No changes required for existing deployments without LDAP TLS
- **Secure Defaults**: Certificate files are mounted with read-only permissions (0444)
- **Flexible Configuration**: Default certificate path works for most scenarios, customizable when needed
- **Standard Helm Support**: Values support standard Helm templating and can be set via `--set`, `--set-file`, or `values.yaml`
