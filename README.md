# Exivity for Kubernetes

## Prerequisites

Currently the images for the application are hosted in private registries, so an
imagePullSecret has to be added to the namespace for any private registry
currently in use. In this case [ghcr](https://ghcr.io).

[Creating an imagePullSecret](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

## Installation with Helm

[Helm](https://helm.sh) must be installed to use the charts. Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

    helm repo add <repo-name> https://charts.exivity.com

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages. You can then run `helm search repo exivity`
to see the charts.

Create a local values file and fill in the respective values:

    echo -e "JWTSecret: xxx\nappKey: xxx\nlicense: xxx" > exivity-values.yaml

To install the exivity chart:

    helm install <chart-name> <repo-name>/exivity --values exivity-values.yaml

## Removing Installation

To uninstall the chart:

    helm delete <chart-name>

To delete the PVCs associated with the release:

    kubectl delete pvc -l app.kubernetes.io/instance=exivity

## Parameters

### Common Params

| Name                             | Description                                             | Default Value   |
|----------------------------------|---------------------------------------------------------|-----------------|
| `ingress.enable`                 | enable creation of an Ingress object                    | `true`          |
| `ingress.host`                   | define ingress host                                     | `localhost`     |
| `ingress.tlsSecret`              | define name for TLS secret                              | `exivity-tls`   |
| `storage.singleNode`             | set all shared PVC accessmodes to 'ReadWriteOne'        | `true`          |
| `storage.helmResourcePolicyKeep` | set helmResourcePolicyKeep for PVCs                     | `false`         |
| `postgresql.enabled`             | install an instance of Postgresql                       | `true`          |
| `postgresql.auth.database`       | name of the database to be used                         | `exivity`       |
| `postgresql.auth.username`       | user for the database                                   | `exivity`       |
| `postgresql.auth.password`       | password for the database                               | `Password12!`   |
| `database.initialise`            | create the 'database-init' Job, applying all migrations | `true`          |
| `rabbitmq.enabled`               | install an instance of RabbitMQ                         | `true`          |
| `rabbitmq.user`                  | username for RabbitMQ                                   | `guest`         |
| `rabbitmq.password`              | password for RabbitMQ                                   | `guest`         |
| `rabbitmq.host`                  | hostname for the RabbitMQ service                       | `rabbit`        |
| `rabbitmq.vhost`                 | vhost for the RabbitMQ service                          | `/`             |
| `rabbitmq.port`                  | port for the RabbitMQ service                           | `5672`          |

### Image Params
All of the services can be defined following this schema.

| Name                        | Description                                         | Default Value                   |
|-----------------------------|-----------------------------------------------------|---------------------------------|
| `service.servicename.image` | name of the image                                   | `docker.io/exivity/servicename` |
| `service.servicename.tag`   | tag of the image, references the Helm Chart version | `exivity-chartversion`          |
