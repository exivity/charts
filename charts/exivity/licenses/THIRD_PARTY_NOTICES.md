# Third-Party Component Licenses

This document contains license and attribution information for third-party
components included in the Exivity Helm Chart.

## Bitnami Helm Charts (PostgreSQL and RabbitMQ)

**Original Source**: https://github.com/bitnami/charts  
**Forked To**: https://github.com/exivity/bitnami-charts  
**Published At**: https://exivity.github.io/bitnami-charts  
**License**: Apache License 2.0 ([Apache-2.0.txt](Apache-2.0.txt))  
**Copyright**: © 2025 Broadcom Inc.  
**SPDX-License-Identifier**: APACHE-2.0

### Integration Details

The Exivity Helm Chart uses forked versions of the Bitnami PostgreSQL and
RabbitMQ charts as dependencies. These charts are used for **testing and
development purposes only**.

**PostgreSQL Chart**:

- **Repository**: https://exivity.github.io/bitnami-charts
- **Version**: 17.0.2
- **Original Source**:
  https://github.com/bitnami/charts/tree/main/bitnami/postgresql

**RabbitMQ Chart**:

- **Repository**: https://exivity.github.io/bitnami-charts
- **Version**: 16.0.17
- **Original Source**:
  https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq

### Deprecation Notice

⚠️ **Important**: The Bitnami charts repository has been deprecated by Broadcom
as of September 29, 2025. The forked charts are provided for testing purposes
only.

**For production deployments**, consider using RabbitMQ Cluster Operator for
Kubernetes or any other external RabbitMQ instances.

### Modifications to Original Charts

The following modifications have been made to the original Bitnami charts:

1. Repository URL changed from `https://charts.bitnami.com/bitnami` to
   `https://exivity.github.io/bitnami-charts`
2. Documentation updated with deprecation notices and migration guidance
3. Chart metadata updated to reflect Exivity's fork hosting

All modifications comply with the Apache License 2.0 terms and maintain
compatibility with the original charts.
