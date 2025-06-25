# Makefile — Exivity Helm Charts: Deployment + Release Testing

# 🏗️  Constants
NFS_STORAGE_CLASS := nfs-client
NFS_CHART_VERSION := 1.8.0
INGRESS_HOSTNAME := exivity.local
HELM_TIMEOUT := 10m

# 🗝️  Dummy secrets for release workflow testing
GPG_KEY_ID            ?= EXIVITY123TEST
GPG_PASSPHRASE        ?= test1234
HELM_RSA_PRIVATE_KEY  ?= LS0tLS1CRUdJTiBQR1AgUFJJVkFURSBLRVkgQkxPQ0stLS0tLQpFeGl2aXR5IFRlc3QgS2V5IDx0ZXN0QGV4aXZpdHkuY29tPgotLS0tLUVORCBQR1AgUFJJVkFURSBLRVkgQkxPQ0stLS0tLQ==

# 🔍  Variables for chart packaging
CHART_DIRS := $(shell find charts -maxdepth 1 -mindepth 1 -type d 2>/dev/null || echo "")
TGZ_FILES  := $(patsubst charts/%,%.tgz,$(CHART_DIRS))


# =====================================================================
# 🚀  MINIKUBE DEPLOYMENT TARGETS 
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



# ---------------------------------------------------------------------



# =====================================================================
# 🧪  RELEASE WORKFLOW TEST 
# =====================================================================

# 🎁  Package every chart in charts/* → <name>-<version>.tgz
package-charts: $(TGZ_FILES)

%.tgz:
	@echo "📦 Helm-packaging $@"
	@CHART_NAME=$(basename $@); \
	if [ -d "charts/$$CHART_NAME" ]; then \
		helm package "charts/$$CHART_NAME" > /dev/null 2>&1; \
	else \
		echo "⚠️  Chart directory charts/$$CHART_NAME not found"; \
	fi

# 🔏  Forge dummy .prov files so downstream scripts still work
package-sign:
	@echo "🔖 Creating fake .prov signature files (no GPG keys used)"
	@if ls *.tgz >/dev/null 2>&1; then \
		for tgz in *.tgz; do \
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
	else \
		echo "   ⚠️  No .tgz files found to sign"; \
	fi

# ✅  Stubbed validation step — we deliberately *skip* helm verify
package-validate:
	@echo "✅ Validation stub → skipping 'helm verify' because using fake signatures"
	@echo "📋 Generated files:"
	@ls -la *.tgz *.prov 2>/dev/null || echo "   (no files found)"

# 🧹  Clean up build artifacts
clean-release:
	@echo "🧹 Removing generated .tgz/.prov files"
	@rm -f *.tgz *.prov fake-signing-key.asc || true

# 📖  Makefile targets

.PHONY: minikube-start minikube-delete deploy-charts deploy-exivity-chart deploy-nfs-chart \
	install-python-deps test lint clean-release package-charts package-sign \
	validate-release
