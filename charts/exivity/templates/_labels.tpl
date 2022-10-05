# Default labels for Exivity k8s objects
{{- define "exivity.default_labels" }}
exivity.k8s/app: exivity
exivity.k8s/name: {{ .Release.Name }}
exivity.k8s/version: {{ .Chart.Version }}
{{- end }}
