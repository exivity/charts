# Images
## CI
Images are build through the Exivity CICD, with versioned and labelled images available per release on dockerhub. By default images only contain the relevant application(s), not the required config for connectivity and runtime configuration. __Most Exivity services will not function with no set config__.

## Config
The Exivity applications are configured with a file located at `/exivity/home/config.json`. Helm and Kubernetes provide a simple method to apply declarative config to the images; supplying the application with a templated _config.json_ by way of mounting the file from a configMap at the desired location.

### Defaults
Some of the applications are the only Exivity process running in that image, and for these a default config meets their needs. This config is mostly information about connectivity with data sources, e.g. PostGres, RabbitMQ.

### Merlin
For a number of the applications, which run in tandem with the Merlin binary, the config must be tailored specifically for the instance of Merlin that will be making the necessary calls. These applications need to be supplied with the basic connectivity configuration as well as some config for Merlin.
