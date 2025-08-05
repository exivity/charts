# Exivity Helm Chart

[![Documentation](https://img.shields.io/badge/docs-helm%20chart-blue?style=flat-square&logo=kubernetes)](https://docs.exivity.com/getting%20started/installation/kubernetes/)

This Helm chart deploys Exivity, a comprehensive cloud metering and billing solution, on Kubernetes clusters.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.0+
- A StorageClass that supports ReadWriteMany access mode (for shared storage)

## Getting Started

### 1. Add the Helm Repository

```bash
helm repo add exivity https://charts.exivity.com
helm repo update
```

### 2. Install the Chart

Install Exivity with your desired release name:

```bash
helm upgrade --install exivity exivity/exivity \
    --namespace exivity \
    --create-namespace \
    --wait \
    --set storage.storageClass=<your-storage-class>
```

Replace `<your-storage-class>` with your preferred storage class that supports ReadWriteMany access mode.

### 3. Storage Solutions

Exivity is tested with various storage solutions including NFS and Longhorn. Here are examples for common setups:

#### NFS Storage with nfs-ganesha-server-and-external-provisioner

```bash
# Install NFS server provisioner
helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
helm install nfs-server nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner \
    --namespace nfs-server \
    --create-namespace \
    --wait \
    --set persistence.enabled=true \
    --set persistence.size=5Gi \
    --set storageClass.name=nfs-client

# Then install Exivity
helm upgrade --install exivity exivity/exivity \
    --namespace exivity \
    --create-namespace \
    --wait \
    --set storage.storageClass=nfs-client
```

#### Longhorn Storage (Beta Support)

If you're using Longhorn, you can install Exivity with:

> **Note**: Longhorn support is currently in beta. While it works, we cannot ensure the same level of stability as NFS storage solutions.

```bash
helm upgrade --install exivity exivity/exivity \
    --namespace exivity \
    --create-namespace \
    --wait \
    --set storage.storageClass=longhorn
```

## Configuration

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `licence` | Exivity license key (use "demo" for evaluation) | `"demo"` |
| `storage.storageClass` | Storage class for persistent volumes | `""` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.host` | Hostname for the ingress | `"exivity"` |

### Example: Custom Values

Create a `values.yaml` file:

```yaml
licence: "your-license-key"
storage:
  storageClass: "nfs-client"
ingress:
  enabled: true
  host: "exivity.example.com"
  tls:
    enabled: true
    secret: "exivity-tls"
```

Install with custom values:

```bash
helm upgrade --install exivity exivity/exivity \
    --namespace exivity \
    --create-namespace \
    --values values.yaml
```

## Advanced Configuration

For detailed configuration options, see the [examples](./charts/exivity/examples/) directory:

- [GUI as Website](./charts/exivity/examples/gui-as-website.yaml) - Configure ingress for web access
- [External PostgreSQL](./charts/exivity/examples/separate-postgresql.yaml) - Use external PostgreSQL
- [External RabbitMQ](./charts/exivity/examples/separate-rabbitmq.yaml) - Use external RabbitMQ
- [Larger PostgreSQL](./charts/exivity/examples/larger-postgresql.yaml) - Scale PostgreSQL resources

## Accessing Exivity

After installation, Exivity will be available at:

- **With Ingress**: `http(s)://<your-hostname>/`

## Uninstalling

To uninstall the chart:

```bash
helm uninstall exivity -n exivity
```

## Support

For more detailed installation instructions, visit the [Exivity Installation Guide](https://docs.exivity.com/getting%20started/installation/kubernetes/).
