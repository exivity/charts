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

{{/*
Validate LDAP certificate configuration with tpl support for multiline strings
*/}}
{{- define "proximity-api.validateLdapCert" -}}
  {{- $hasCert := false -}}
  {{- $hasPath := false -}}
  
  {{/* Check if certificate exists and is non-empty (with tpl parsing) */}}
  {{- if .Values.ldap.tlsCacert -}}
    {{- $certContent := tpl (.Values.ldap.tlsCacert | toString) . -}}
    {{- if ne (trim $certContent) "" -}}
      {{- $hasCert = true -}}
    {{- end -}}
  {{- end -}}
  
  {{/* Check if path exists and is non-empty */}}
  {{- if .Values.ldap.tlsCacertPath -}}
    {{- $pathContent := tpl (.Values.ldap.tlsCacertPath | toString) . -}}
    {{- if ne (trim $pathContent) "" -}}
      {{- $hasPath = true -}}
    {{- end -}}
  {{- end -}}

  {{/* Validation logic */}}
  {{- if and $hasCert (not $hasPath) -}}
    {{- required "ldap.tlsCacertPath must be set when providing ldap.tlsCacert" "" -}}
  {{- end -}}
  {{/* Note: We allow tlsCacertPath to be set as a default without requiring tlsCacert */}}
  {{/* Only require tlsCacert when both are provided and we're actually using LDAP TLS */}}
{{- end -}}
