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

To uninstall the chart:

    helm delete <chart-name>
