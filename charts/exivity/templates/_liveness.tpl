{{- define "exivity.nfs-liveness" }}
readinessProbe:
  httpGet:
    path: /healthz
    port: 8000
  periodSeconds: 30
  failureThreshold: 4
livenessProbe:
  httpGet:
    path: /healthz
    port: 8000
  initialDelaySeconds: 30
  periodSeconds: 30
  failureThreshold: 12
{{- end }}
