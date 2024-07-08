{{- define "exivity.tristan-probes" }}
readinessProbe:
  httpGet:
    path: /readiness
    port: 8080
  initialDelaySeconds: 3
  periodSeconds: 5
livenessProbe:
  httpGet:
    path: /liveness
    port: 8080
  initialDelaySeconds: 3
  periodSeconds: 5
{{- end }}
