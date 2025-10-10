# Third-Party Component Licenses

This document contains license and attribution information for third-party
components included in the Exivity Helm Chart.

## Bitnami Helm Charts (PostgreSQL and RabbitMQ)

**Source**: [https://github.com/bitnami/charts](https://github.com/bitnami/charts)  
**Mirror**: [https://github.com/exivity/bitnami-charts](https://github.com/exivity/bitnami-charts)  
**License**: Apache License 2.0  
**Copyright**: © 2025 Broadcom Inc.  
**SPDX-License-Identifier**: APACHE-2.0  
**License Text**: See [Apache-2.0.txt](Apache-2.0.txt)

### Integration Details

The Exivity Helm Chart uses mirrored versions of the Bitnami PostgreSQL and RabbitMQ
charts as dependencies. These charts are used for **testing and development purposes only**.

**PostgreSQL Chart**:
- **Repository**: https://exivity.github.io/bitnami-charts
- **Version**: 17.0.2
- **Original Source**: https://github.com/bitnami/charts/tree/main/bitnami/postgresql

**RabbitMQ Chart**:
- **Repository**: https://exivity.github.io/bitnami-charts
- **Version**: 16.0.17
- **Original Source**: https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq

### Deprecation Notice

⚠️ **Important**: The Bitnami charts repository has been deprecated by Broadcom as of
September 29, 2025. The mirrored charts are provided for testing purposes only.

**For production deployments**, use one of these alternatives:
- RabbitMQ Cluster Operator for Kubernetes
- Managed RabbitMQ services (e.g., CloudAMQP, AWS MQ)
- External RabbitMQ instances with proper high-availability setup

### Original Copyright Notice

```
Copyright © 2025 Broadcom. The term "Broadcom" refers to Broadcom Inc.
and/or its subsidiaries.

SPDX-License-Identifier: APACHE-2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

### Modifications

The following modifications have been made to the original Bitnami charts:

1. Repository URL changed from `https://charts.bitnami.com/bitnami` to `https://exivity.github.io/bitnami-charts`
2. Documentation updated with deprecation notices and migration guidance
3. Chart metadata updated to reflect Exivity's mirror hosting

All modifications comply with the Apache License 2.0 terms.

## License Compliance

This document and the accompanying license files ensure full compliance with the
Apache License 2.0 requirements for attribution and redistribution. All
modifications to third-party components are clearly documented within the source
files and this notice.

For the complete text of the Apache License 2.0, see
[Apache-2.0.txt](Apache-2.0.txt).
