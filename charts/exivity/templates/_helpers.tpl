{{/* 
Merge global.securityContext with any component override,
and emit the whole block indented 8 spaces.
*/}}
{{- define "exivity.securityContext" -}}
  {{- $root     := .root -}}
  {{- $name     := .component -}}
  {{- $globalSC := $root.Values.global.securityContext -}}
  {{- $svc      := index $root.Values.service $name | default dict -}}
  {{- $override := $svc.securityContext        | default dict -}}
  {{- $merged   := merge $globalSC $override   -}}
{{- toYaml $merged | nindent 8 -}}
{{- end -}}

{{- define "exivity.userGroup" -}}
{{- $root     := .root -}}
{{- $name     := .component -}}
{{- $globalSC := $root.Values.global.securityContext -}}
{{- $svc      := index $root.Values.service $name | default dict -}}
{{- $override := $svc.securityContext        | default dict -}}
{{- $merged   := merge $globalSC $override   -}}
{{- printf "%s:%s" $merged.runAsUser $merged.runAsGroup -}}
{{- end -}}
