# RabbitMQ Configuration Migration Guide

## Overview

This guide explains the RabbitMQ configuration in the Exivity Helm chart
following the deprecation of Bitnami's RabbitMQ chart on September 29, 2025.

## ⚠️ IMPORTANT: Bitnami Charts Deprecation

**Effective September 29, 2025**, the Bitnami Helm charts repository was
deprecated by Broadcom. Exivity has mirrored the Bitnami PostgreSQL and RabbitMQ
charts for **testing and development purposes only**.

### Current Configuration

The Exivity chart uses mirrored Bitnami charts from:

- **Repository**: https://exivity.github.io/bitnami-charts
- **Source**: Forked from https://github.com/bitnami/charts
- **PostgreSQL Version**: 17.0.2
- **RabbitMQ Version**: 16.0.17

### Testing-Only Usage

```yaml
# Chart.yaml dependencies
dependencies:
  - name: postgresql
    repository: https://exivity.github.io/bitnami-charts
    version: 17.0.2
  - name: rabbitmq
    repository: https://exivity.github.io/bitnami-charts
    version: 16.0.17
```

**Container Images** (temporary compatibility solution):

```yaml
# values.yaml
postgresql:
  image:
    registry: docker.io
    repository: bitnamilegacy/postgresql

rabbitmq:
  image:
    registry: docker.io
    repository: bitnamilegacy/rabbitmq
```

### Production Deployment Options

⚠️ **The mirrored Bitnami charts are NOT recommended for production use.**

For production deployments, consider using:

**RabbitMQ Cluster Operator**

- Official Kubernetes operator from RabbitMQ team
- Native Kubernetes integration
- Production-ready with proper clustering
- Documentation: https://www.rabbitmq.com/kubernetes/operator/operator-overview

## Configuration for Testing

### Embedded RabbitMQ (Testing Only)

The mirrored Bitnami RabbitMQ chart can be used for testing:

```yaml
# values.yaml - TESTING ONLY
rabbitmq:
  enabled: true
  image:
    registry: docker.io
    repository: bitnamilegacy/rabbitmq
  auth:
    username: user
    password: changeme
```

### External RabbitMQ Configuration

For production, disable the embedded chart and connect to external RabbitMQ:

```yaml
# values.yaml - PRODUCTION
rabbitmq:
  enabled: false # Disable embedded RabbitMQ chart

  # External RabbitMQ configuration
  host: "rabbitmq.example.com" # Hostname of external RabbitMQ server
  port: 5672 # Port number (default: 5672)
  vhost: "" # Virtual host (optional)
  secure: false # Set to true to enable TLS

  # Authentication (uses same credentials structure)
  auth:
    username: user
    password: changeme
```

## Migration to External RabbitMQ

To migrate from the embedded Bitnami RabbitMQ to an external RabbitMQ instance:

1. Deploy your production RabbitMQ solution (refer to the solution's official
   documentation)
2. Update your Exivity Helm values to disable the embedded chart and configure
   the external connection:

```yaml
rabbitmq:
  enabled: false # Disable embedded chart
  host: "<your-rabbitmq-host>"
  port: 5672
  auth:
    username: "<username>"
    password: "<password>"
```

3. Upgrade your Exivity deployment with the updated values

For detailed setup instructions, refer to the official documentation of your
chosen RabbitMQ solution.

## License Compliance

The mirrored Bitnami charts are distributed under the Apache License 2.0. See
[LICENSE.md](LICENSE.md) and
[licenses/THIRD_PARTY_NOTICES.md](licenses/THIRD_PARTY_NOTICES.md) for complete
license information and attribution.

## Support

- **Exivity Issues**: support@exivity.com
- **RabbitMQ Operator**: https://github.com/rabbitmq/cluster-operator/issues
- **Bitnami Charts** (deprecated): https://github.com/bitnami/charts
