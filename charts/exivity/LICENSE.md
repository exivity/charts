# License Information

This Helm chart contains components from multiple sources under different
licenses.

## Exivity Components

The Exivity application and its associated Helm chart templates, configurations,
and documentation are proprietary software.

**Copyright**: © Exivity B.V.  
**Website**: https://exivity.com

All rights reserved. No part of the Exivity software may be reproduced,
distributed, or transmitted in any form or by any means without the prior
written permission of Exivity B.V.

---

## Third-Party Dependencies

This chart includes third-party open-source components that are subject to their
own licenses.

### Mirrored Bitnami Charts

#### Background

Bitnami (now part of Broadcom Inc.) deprecated their public Helm charts
repository in September 2025. To ensure continuity for our users during this
transition, Exivity has created mirrors of the PostgreSQL and RabbitMQ charts.

**Important**: These mirrored charts are provided **for testing and development
purposes only**. For production deployments, please use the recommended
alternatives documented in `docs/RABBITMQ_DEPLOYMENT_OPTIONS.md`.

#### PostgreSQL Helm Chart

**Original Source**:
https://github.com/bitnami/charts/tree/main/bitnami/postgresql (archived)  
**Mirrored Repository**: https://exivity.github.io/bitnami-charts  
**License**: Apache License 2.0  
**Copyright**: © Broadcom Inc. (formerly VMware, Inc.)

#### RabbitMQ Helm Chart

**Original Source**:
https://github.com/bitnami/charts/tree/main/bitnami/rabbitmq (archived)  
**Mirrored Repository**: https://exivity.github.io/bitnami-charts  
**License**: Apache License 2.0  
**Copyright**: © Broadcom Inc. (formerly VMware, Inc.)

**Full Apache License 2.0 text**:
[licenses/Apache-2.0.txt](licenses/Apache-2.0.txt)

### Container Images

#### PostgreSQL Container Image

**Image**: `docker.io/bitnamilegacy/postgresql`  
**License**: Apache License 2.0 (container packaging)  
**Copyright**: © Broadcom Inc.

#### RabbitMQ Container Image

**Image**: `docker.io/bitnamilegacy/rabbitmq`  
**License**: Apache License 2.0 (container packaging)  
**Copyright**: © Broadcom Inc.

**Note**: The `bitnamilegacy` images are deprecated and will eventually be
removed by Broadcom. They are provided temporarily for compatibility.

---

## Apache License 2.0 Compliance

The mirrored Bitnami charts (PostgreSQL and RabbitMQ) are distributed under the
Apache License 2.0, in accordance with the terms of the original Bitnami charts.

### Copyright Notice

```
Copyright © 2025 Broadcom. The term "Broadcom" refers to Broadcom Inc. and/or its subsidiaries.
SPDX-License-Identifier: APACHE-2.0
```

**Original Work**: https://github.com/bitnami/charts  
**License**: Apache License 2.0  
**Full License Text**: [licenses/Apache-2.0.txt](licenses/Apache-2.0.txt)

### Apache License 2.0 Requirements Met

Per Apache License 2.0 Section 4, Exivity has:

1. ✅ **Included a copy of the License** (Section 4a)

   - See [licenses/Apache-2.0.txt](licenses/Apache-2.0.txt)

2. ✅ **Documented modifications** (Section 4b)

   - Changes are listed below in "Modifications to Original Charts"

3. ✅ **Retained copyright and attribution notices** (Section 4c)

   - Original Bitnami/Broadcom copyright preserved
   - SPDX-License-Identifier maintained

4. ✅ **Included NOTICE file contents** (Section 4d)
   - If the original charts included a NOTICE file, those notices are preserved
   - Original NOTICE: https://github.com/bitnami/charts/blob/main/NOTICE (if
     exists)

### Attribution

This product includes Helm charts originally created and maintained by
**Bitnami** (now part of **Broadcom Inc.**).

**Original Source**: https://github.com/bitnami/charts  
**Original License**: Apache License 2.0  
**Original Copyright**: © 2025 Broadcom Inc.

We acknowledge and thank the Bitnami team, Broadcom Inc., and the open-source
community for their contributions.

### Modifications to Original Charts

The following modifications have been made to the original Bitnami charts:

1. **Repository URL**: Changed from `https://charts.bitnami.com/bitnami` to
   `https://exivity.github.io/bitnami-charts`
2. **Documentation**: Added deprecation notices and migration guidance
3. **Chart Metadata**: Updated to reflect Exivity's mirror hosting
4. **Values Documentation**: Added warnings about testing-only usage

**All modifications comply with Apache License 2.0 terms and maintain
compatibility with the original charts.**

---

## Usage Restrictions

### Testing Only

The mirrored charts and `bitnamilegacy` images are provided for:

- ✅ Testing and development
- ✅ Evaluation and proof-of-concept
- ❌ **NOT for production use**

### Production Recommendations

For production, use:

1. **RabbitMQ Cluster Operator** - Official Kubernetes operator
2. **Managed Services** - AWS MQ, CloudAMQP, etc.
3. **Self-Hosted External** - Official RabbitMQ images

See `docs/RABBITMQ_DEPLOYMENT_OPTIONS.md` for guidance.

---

## Disclaimer

**THE MIRRORED CHARTS AND IMAGES ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
KIND. IN NO EVENT SHALL EXIVITY B.V., BROADCOM INC., OR ANY CONTRIBUTOR BE
LIABLE FOR ANY DAMAGES ARISING FROM THEIR USE.**

---

## Contact

- **Exivity Support**: support@exivity.com
- **Documentation**: https://docs.exivity.com

**Last Updated**: October 10, 2025  
**Chart Version**: 3.36.1
