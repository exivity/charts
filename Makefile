# Constants
NFS_STORAGE_CLASS := nfs-client
NFS_CHART_VERSION := 1.8.0

PVC_DEFAULT_STORAGE_SIZE := 200Mi

INGRESS_HOSTNAME := exivity.local

HELM_TIMEOUT := 10m

# Define Minikube start with a specific driver
minikube-start:
	@minikube start --memory 8192 --cpus 2
	@minikube addons enable ingress

# Define Minikube delete
minikube-delete:
	@minikube delete

# Deploy Exivity Helm chart to Minikube
deploy-exivity-chart:
	@helm upgrade --install exivity ./charts/exivity \
        --namespace exivity \
        --create-namespace \
        --wait \
        --debug \
        --timeout $(HELM_TIMEOUT) \
        --set storage.storageClass=$(NFS_STORAGE_CLASS) \
        --set storage.pvcSizes.log.chronos=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.log.edify=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.log.executor=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.log.glass=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.log.griffon=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.log.pigeon=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.log.proximityApi=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.log.proximityCli=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.log.transcript=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.log.use=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.config.etl=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.config.griffon=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.config.chronos=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.data.exported=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.data.extracted=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.data.import=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set storage.pvcSizes.data.report=$(PVC_DEFAULT_STORAGE_SIZE) \
        --set ingress.host=$(INGRESS_HOSTNAME) \
        --set ingress.ingressClassName="nginx" \
        --set logLevel.backend="debug" \
        --set service.tag="daily"

# Deploy NFS Helm chart to Minikube
# This is a dependency for the exivity Helm chart
deploy-nfs-chart:
	@helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
	@helm install nfs-server nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner \
        --version $(NFS_CHART_VERSION) \
        --namespace nfs-server \
        --create-namespace \
        --wait \
        --debug \
        --timeout $(HELM_TIMEOUT) \
        --set persistence.enabled=true \
        --set persistence.size=5Gi \
        --set storageClass.name=$(NFS_STORAGE_CLASS) \
        --set storageClass.allowVolumeExpansion=true \
        --set 'storageClass.mountOptions[0]=nfsvers=4.2' \
        --set 'storageClass.mountOptions[1]=rsize=4096' \
        --set 'storageClass.mountOptions[2]=wsize=4096' \
        --set 'storageClass.mountOptions[3]=hard' \
        --set 'storageClass.mountOptions[4]=retrans=3' \
        --set 'storageClass.mountOptions[5]=proto=tcp' \
        --set 'storageClass.mountOptions[6]=noatime' \
        --set 'storageClass.mountOptions[7]=nodiratime'

# Deploy all Helm charts
deploy-charts: deploy-nfs-chart deploy-exivity-chart

# Install Python dependencies
install-python-deps:
	@echo "Installing Python dependencies..."
	@pip install -r test/requirements.txt

# Test Helm chart
test:
	@echo "Running tests..."
	@python3 test/test.py --hostname $(INGRESS_HOSTNAME) --ip $$(minikube ip)

# Lint Helm chart
lint:
	@helm lint charts/exivity

# Makefile targets
.PHONY: minikube-start minikube-delete deploy-charts deploy-exivity-chart deploy-nfs-chart install-python-deps test
