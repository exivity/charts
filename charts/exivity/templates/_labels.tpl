# Some text explaining this stuff goed here
{{- define "exivity.default_labels" }}
exivity.k8s/app: exivity
exivity.k8s/name: {{ .Release.Name }}
exivity.k8s/version: {{ .Chart.Version }}
exivity.k8s/namespace: {{ .Release.Namespace }}
{{- end }}
