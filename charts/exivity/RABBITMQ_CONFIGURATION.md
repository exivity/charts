# RabbitMQ Configuration

## Overview

Bitnami's RabbitMQ chart was deprecated on September 29, 2025. Exivity has
forked the Bitnami charts for testing purposes only.

## Current Setup

- **Repository**: https://exivity.github.io/bitnami-charts (forked from Bitnami)
- **RabbitMQ Version**: 16.0.17
- **Container Image**: `bitnamilegacy/rabbitmq` (temporary compatibility)

⚠️ **For testing and development only - NOT for production use.**

## Configuration Options

### For Testing: Embedded RabbitMQ

By default, the chart uses the embedded RabbitMQ with `rabbitmq.enabled=true`.
See `values.yaml` for configuration options.

### For Production: External RabbitMQ

Disable the embedded chart and configure external connection:

```yaml
rabbitmq:
  enabled: false
  host: "<your-rabbitmq-host>"
  port: 5672
  auth:
    username: "<username>"
    password: "<password>"
```

See `values.yaml` for all available RabbitMQ configuration options.

## Production Recommendations

For production deployments, consider using **RabbitMQ Cluster Operator** for
Kubernetes or any other external RabbitMQ instances.

**Documentation**:
https://www.rabbitmq.com/kubernetes/operator/operator-overview

## License Compliance

The forked Bitnami charts are distributed under the Apache License 2.0. See
[licenses/THIRD_PARTY_NOTICES.md](licenses/THIRD_PARTY_NOTICES.md) for complete
license information and attribution.

## Support

- **Exivity Issues**: support@exivity.com
- **RabbitMQ Operator**: https://github.com/rabbitmq/cluster-operator/issues
- **Bitnami Charts** (deprecated): https://github.com/bitnami/charts
