{{/* vim: set filetype=mustache: */}}
{{/*
Return the node selector for a component.
*/}}
{{- define "exivity.nodeSelector" -}}
{{- $nodeSelector := .component.nodeSelector | default .global.nodeSelector -}}
{{- if $nodeSelector }}
nodeSelector:
{{ toYaml $nodeSelector | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Return the node affinity for a component.
*/}}
{{- define "exivity.nodeAffinity" -}}
{{- $nodeAffinity := .component.nodeAffinity | default .global.nodeAffinity -}}
{{- if $nodeAffinity }}
nodeAffinity:
{{ toYaml $nodeAffinity | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Return the tolerations for a component.
*/}}
{{- define "exivity.tolerations" -}}
{{- $tolerations := .component.tolerations | default .global.tolerations -}}
{{- if $tolerations }}
tolerations:
{{ toYaml $tolerations | nindent 2 }}
{{- end }}
{{- end -}}
