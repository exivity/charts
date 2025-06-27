{{/* vim: set filetype=mustache: */}}
{{/*
Return the node selector for a component.
*/}}
{{- define "exivity.nodeSelector" -}}
{{- $compNodeSelector := dict -}}
{{- if .component -}}
{{- $compNodeSelector = .component.nodeSelector -}}
{{- end -}}
{{- $nodeSelector := $compNodeSelector | default .global.nodeSelector -}}
{{- if $nodeSelector }}
nodeSelector:
{{ toYaml $nodeSelector | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Return the node affinity for a component.
*/}}
{{- define "exivity.nodeAffinity" -}}
{{- $compNodeAffinity := dict -}}
{{- if .component -}}
{{- $compNodeAffinity = .component.nodeAffinity -}}
{{- end -}}
{{- $nodeAffinity := $compNodeAffinity | default .global.nodeAffinity -}}
{{- if $nodeAffinity }}
nodeAffinity:
{{ toYaml $nodeAffinity | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Return the tolerations for a component.
*/}}
{{- define "exivity.tolerations" -}}
{{- $compTolerations := dict -}}
{{- if .component -}}
{{- $compTolerations = .component.tolerations -}}
{{- end -}}
{{- $tolerations := $compTolerations | default .global.tolerations -}}
{{- if $tolerations }}
tolerations:
{{ toYaml $tolerations | nindent 2 }}
{{- end }}
{{- end -}}
