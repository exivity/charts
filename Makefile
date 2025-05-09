# Constants
NFS_STORAGE_CLASS := nfs-client
NFS_CHART_VERSION := 1.8.0

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
        --timeout $(HELM_TIMEOUT) \
        --set storage.storageClass=$(NFS_STORAGE_CLASS) \
        --set ingress.host=$(INGRESS_HOSTNAME) \
        --set ingress.ingressClassName="nginx" \
        --set logLevel.backend="debug" \
        --set service.tag="daily" \

# Deploy NFS Helm chart to Minikube
# This is a dependency for the exivity Helm chart
deploy-nfs-chart:
	@helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
	@helm install nfs-server nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner \
        --version $(NFS_CHART_VERSION) \
        --namespace nfs-server \
        --create-namespace \
        --wait \
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
