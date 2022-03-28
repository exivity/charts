## Usage

[Helm](https://helm.sh) must be installed to use the charts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

Once Helm has been set up correctly, add the repo as follows:

  helm repo add exivity https://fuzzy-memory-d2c7cb18.pages.github.io/

If you had already added this repo earlier, run `helm repo update` to retrieve
the latest versions of the packages.  You can then run `helm search repo
exivity` to see the charts.

To install the exivity chart:

    helm install my-<chart-name> exivity/exivity

To uninstall the chart:

    helm delete my-<chart-name>
