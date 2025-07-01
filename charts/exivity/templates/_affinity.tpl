{{/* vim: set filetype=mustache: */}}
{{/*
Return the node selector for a component.
*/}}
{{- define "exivity.nodeSelector" -}}
{{- $nodeSelector := dict -}}
{{- if and $.Values (hasKey $.Values "global") -}}
  {{- $nodeSelector = $.Values.global.nodeSelector | default dict -}}
{{- end -}}
{{- if and .component (hasKey .component "nodeSelector") -}}
  {{- $nodeSelector = .component.nodeSelector -}}
{{- end -}}
{{- if $nodeSelector -}}
nodeSelector:
{{ toYaml $nodeSelector | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Return the node affinity for a component.
*/}}
{{- define "exivity.nodeAffinity" -}}
{{- $nodeAffinity := dict -}}
{{- if and $.Values (hasKey $.Values "global") -}}
  {{- $nodeAffinity = $.Values.global.nodeAffinity | default dict -}}
{{- end -}}
{{- if and .component (hasKey .component "nodeAffinity") -}}
  {{- $nodeAffinity = .component.nodeAffinity -}}
{{- end -}}
{{- if $nodeAffinity -}}
nodeAffinity:
{{ toYaml $nodeAffinity | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Return the tolerations for a component.
*/}}
{{- define "exivity.tolerations" -}}
{{- $tolerations := list -}}
{{- if and $.Values (hasKey $.Values "global") -}}
  {{- $tolerations = $.Values.global.tolerations | default list -}}
{{- end -}}
{{- if and .component (hasKey .component "tolerations") -}}
  {{- $tolerations = .component.tolerations -}}
{{- end -}}
{{- if $tolerations -}}
tolerations:
{{ toYaml $tolerations | nindent 2 }}
{{- end }}
{{- end -}}
