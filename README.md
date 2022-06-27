# Exivity helm charts for Kubernetes

Please refer to the
[Kubernetes article on the Exivity documentation](https://docsbeta.netlify.app/Getting%20Started/Installation/Kubernetes)
to get started with the Exivity helm charts.

## Installation with Helm

[Helm](https://helm.sh) must be installed to use the charts. Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

    helm repo add <repo-name> https://charts.exivity.com

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages. You can then run `helm search repo exivity`
to see the charts.

To install the exivity chart:

    helm install <chart-name> <repo-name>/exivity

## Removing Installation

To uninstall the
chart:[](https://app.gitbook.com/o/-LFqrgt4ppw0Nm3u4I34/s/-LJZc552bE3pyF95a_wx/~/changes/ZIKcue4LQav7SDIzpOhs/product/development/deploys/kubernetes)

    helm delete <chart-name>

To delete the PVCs associated with the release:

    kubectl delete pvc -l app.kubernetes.io/instance=exivity

## Parameters

### Common Params

| Name                             | Description                                             | Default Value      |
| -------------------------------- | ------------------------------------------------------- | ------------------ |
| `ingress.enable`                 | enable creation of an Ingress object                    | `true`             |
| `ingress.host`                   | define ingress host                                     | `localhost`        |
| `ingress.ingressClassName`       | set ingressClassName for the ingress                    | `nginx`            |
| `ingress.generateCert`           | generate a self-signed cert using the given hostname    | `true`             |
| `ingress.serviceType`            | define Type for published Services                      | `LoadBalancer`     |
| `ingress.tlsSecret`              | define name for TLS secret to be use in the ingress     | `exivity-tls`      |
| `ingress.trustedProxy`           | define a list of trusted proxies for PHP Laravel        |                    |
| `storage.helmResourcePolicyKeep` | set helmResourcePolicyKeep for PVCs                     | `true`             |
| `storage.sharedVolumeAccessMode` | set accessMode for shared volumes                       | `ReadWriteMany`    |
| `storage.storageClass`           | set storageClassName for PVCs                           |                    |
| `postgresql.install`             | install an instance of Postgresql                       | `true`             |
| `postgresql.auth.database`       | name of the database to be used                         | `exivity`          |
| `postgresql.auth.username`       | user for the database                                   | `exivity`          |
| `postgresql.auth.password`       | password for the database                               | `Password12!`      |
| `database.initialise`            | create the 'database-init' Job, applying all migrations | `true`             |
| `database.fullnameOverride`      | sets the Servicename for the PSQL service               | `exivity-postgres` |
| `rabbitmq.install`               | install an instance of RabbitMQ                         | `true`             |
| `rabbitmq.user`                  | username for RabbitMQ                                   | `guest`            |
| `rabbitmq.password`              | password for RabbitMQ                                   | `guest`            |
| `rabbitmq.host`                  | sets the Servicename for the RabbitMQ service           | `rabbit`           |
| `rabbitmq.vhost`                 | vhost for the RabbitMQ service                          | `/`                |
| `rabbitmq.port`                  | port for the RabbitMQ service                           | `5672`             |

### Image Params

All of the services can be defined following this schema.

| Name                        | Description                                         | Default Value                   |
| --------------------------- | --------------------------------------------------- | ------------------------------- |
| `service.servicename.image` | name of the image                                   | `docker.io/exivity/servicename` |
| `service.servicename.tag`   | tag of the image, references the Helm Chart version | `exivity-$CHARTVERSION`         |
