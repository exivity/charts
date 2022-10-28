{{/* Default labels for Exivity k8s objects */}}
{{- define "exivity.labels" }}
{{- include "exivity.matchLabels" . }}
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{- define "exivity.matchLabels" }}
app.kubernetes.io/app: {{ .Chart.Name }}
app.kubernetes.io/name: {{  include "exivity.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
