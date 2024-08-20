{{- define "exivity.nfs-liveness" }}
readinessProbe:
  httpGet:
    path: /healthz
    port: 8000
  periodSeconds: 5
  failureThreshold: 1
livenessProbe:
  httpGet:
    path: /healthz
    port: 8000
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 6
{{- end }}
