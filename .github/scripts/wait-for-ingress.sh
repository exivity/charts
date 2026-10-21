#!/usr/bin/env bash
set -euo pipefail

kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=180s

# A ready controller pod can precede webhook endpoints and certificate setup.
# Exercise admission without creating a real Ingress or disabling validation.
probe_file=$(mktemp)
trap 'rm -f "$probe_file"' EXIT
cat > "$probe_file" <<'YAML'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ci-ingress-admission-probe
spec:
  ingressClassName: nginx
  rules:
    - host: ci-ingress-probe.invalid
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ci-ingress-probe
                port:
                  number: 80
YAML

for ((attempt = 1; attempt <= 30; attempt++)); do
  if kubectl --request-timeout=10s create --dry-run=server -f "$probe_file"; then
    echo "Ingress admission webhook is ready."
    exit 0
  fi
  echo "Waiting for ingress admission webhook ($attempt/30)..."
  sleep 2
done

echo "Ingress admission webhook did not become ready." >&2
exit 1
