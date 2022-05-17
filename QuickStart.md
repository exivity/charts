# Quickstart
## Prerequisites

1. local cluster. Multiple options to run a local cluster;
    1. docker-for-desktop
    1. kind
    1. microk8s
    1. minikube

    This guide has been tested on minikube
1. `kubectl`, with a correct kubeconfig, check with `kubectl version`
1. `helm` cli. check with `helm version`

## Installing

1. add the repo: `helm repo add exivity https://charts.exivity.com`
1. verify the repo is added: `helm search repo exivity`
1. create a namespace: `kubectl create ns exivity-quickstart`
1. install the helm-chart: `helm install -n exivity-quickstart exivity-quickstart exivity-quickstart/exivity -f https://raw.githubusercontent.com/exivity/charts/main/charts/exivity/examples/quickstart-config.yaml`

!!
## Verify Installation
1. enable ingress, on minikube this can be done with `minikube addons enable ingress`
1. browse to [localhost](https://localhost)
1. login using _username: admin_ and _password: exivity_
