{{- define "exivity.probes" }}
{{- if .Values.probes.livenessProbe.enabled }}
livenessProbe:
  httpGet:
    path: /healthz
    port: 8000
  initialDelaySeconds: {{ .Values.probes.livenessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.probes.livenessProbe.periodSeconds }}
  failureThreshold: {{ .Values.probes.livenessProbe.failureThreshold }}
{{- end }}
{{- if .Values.probes.readinessProbe.enabled }}
readinessProbe:
  httpGet:
    path: /healthz
    port: 8000
  initialDelaySeconds: {{ .Values.probes.readinessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.probes.readinessProbe.periodSeconds }}
  failureThreshold: {{ .Values.probes.readinessProbe.failureThreshold }}
{{- end }}
{{- end }}
