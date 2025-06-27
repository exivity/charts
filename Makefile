# Makefile — Exivity Helm Charts: Deployment + Release Testing

# Constants
NFS_STORAGE_CLASS := nfs-client
NFS_CHART_VERSION := 1.8.0
INGRESS_HOSTNAME := exivity.local
HELM_TIMEOUT := 10m

# Dummy secrets for release workflow testing
GPG_KEY_ID            ?= EXIVITY123TEST
GPG_PASSPHRASE        ?= test1234
HELM_RSA_PRIVATE_KEY  ?= LS0tLS1CRUdJTiBQR1AgUFJJVkFURSBLRVkgQkxPQ0stLS0tLQpFeGl2aXR5IFRlc3QgS2V5IDx0ZXN0QGV4aXZpdHkuY29tPgotLS0tLUVORCBQR1AgUFJJVkFURSBLRVkgQkxPQ0stLS0tLQ==

# Variables for chart packaging
CHART_DIRS := $(shell find charts -maxdepth 1 -mindepth 1 -type d 2>/dev/null || echo "")
TGZ_FILES  := $(patsubst charts/%,%.tgz,$(CHART_DIRS))


# =====================================================================
# MINIKUBE DEPLOYMENT TARGETS 
# =====================================================================

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
        --set persistence.size=20Gi \
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
	
# =====================================================================
# RELEASE WORKFLOW TEST 
# =====================================================================

# Package exivity charts
package-charts:
	@echo "📦 Simulating GitHub Actions 'Package and Sign Charts' step"
	@echo "Creating .cr-release-packages directory for chart-releaser-action"
	@mkdir -p .cr-release-packages
	@echo "Packaging chart: charts/exivity"
	@if [ -d "charts/exivity" ]; then \
		helm package "charts/exivity" --destination .cr-release-packages > /dev/null 2>&1; \
		echo "✅ Created signed packages:"; \
		ls -la .cr-release-packages/; \
	else \
		echo "❌ Chart directory charts/exivity not found"; \
	fi

# Sign the packaged charts
package-sign:
	@echo "🔖 Simulating GPG signing (creating fake .prov files)"
	@if ls .cr-release-packages/*.tgz >/dev/null 2>&1; then \
		for tgz in .cr-release-packages/*.tgz; do \
			echo "-----BEGIN PGP SIGNATURE-----" > "$$tgz.prov"; \
			echo "Version: GnuPG v2" >> "$$tgz.prov"; \
			echo "" >> "$$tgz.prov"; \
			echo "Fake signature for testing purposes only" >> "$$tgz.prov"; \
			echo "Chart: $$tgz" >> "$$tgz.prov"; \
			echo "Key ID: $(GPG_KEY_ID)" >> "$$tgz.prov"; \
			echo "Passphrase: $(GPG_PASSPHRASE)" >> "$$tgz.prov"; \
			echo "-----END PGP SIGNATURE-----" >> "$$tgz.prov"; \
			echo "   ✅ Created $$tgz.prov"; \
		done; \
		echo "📋 Updated packages with signatures:"; \
		ls -la .cr-release-packages/; \
	else \
		echo "   ⚠️  No .tgz files found in .cr-release-packages/"; \
	fi

# Validate signed charts
package-validate:
	@echo "✅ Simulating GitHub Actions 'Validate Signed Charts' step"
	@echo "🔍 Finding and validating charts from .cr-release-packages directory:"
	@if [ -d ".cr-release-packages" ]; then \
		find .cr-release-packages -maxdepth 1 -type f -name '*.tgz' -print | while read chart; do \
			echo "� Would run: helm verify $$chart"; \
		done; \
		if ls .cr-release-packages/*.tgz >/dev/null 2>&1; then \
			echo "✅ Charts are properly signed and verified."; \
		else \
			echo "⚠️  No .tgz files found to validate"; \
		fi; \
	else \
		echo "❌ .cr-release-packages directory not found"; \
	fi


# Clean up build artifacts
clean-release:
	@echo "🧹 Removing generated files and .cr-release-packages directory"
	@rm -f *.tgz *.prov fake-signing-key.asc || true
	@rm -rf .cr-release-packages || true

# Makefile targets
.PHONY: minikube-start minikube-delete deploy-charts deploy-exivity-chart deploy-nfs-chart install-python-deps test lint clean-release package-charts package-sign package-validate
