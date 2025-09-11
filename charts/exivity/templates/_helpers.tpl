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
Validate and generate APP_KEY for Laravel applications.
This function ensures APP_KEY meets Laravel's encryption requirements to prevent runtime errors.

Usage: {{ include "exivity.appKey" . }}

Returns base64-encoded APP_KEY value that can be used directly in secret data.

Validation rules:
- Plain keys: Must be exactly 32 characters (for AES-256-CBC)
- Base64 keys: Must have 'base64:' prefix and decode to 16 or 32 bytes (for AES-128/AES-256)
- Empty/missing: Generates secure random 32-character key
- During upgrades: Reuses existing secret if no new key provided

Fails with descriptive error if APP_KEY doesn't meet Laravel requirements.
*/}}
{{- define "exivity.appKey" -}}
  {{- $existingSecret := "" -}}
  {{- if .Release.IsUpgrade -}}
    {{- $existingSecret = lookup "v1" "Secret" .Release.Namespace (printf "%s-app-key" (include "exivity.fullname" .)) -}}
  {{- end -}}
  
  {{- if and .Values.secret.appKey (ne .Values.secret.appKey "") -}}
    {{/* Validate provided APP_KEY for Laravel compatibility */}}
    {{- $appKey := .Values.secret.appKey -}}
    {{- if hasPrefix "base64:" $appKey -}}
      {{/* Validate base64 format APP_KEY */}}
      {{- $base64Part := $appKey | trimPrefix "base64:" -}}
      {{- $decoded := $base64Part | b64dec -}}
      {{- $decodedLen := len $decoded -}}
      {{- if and (ne $decodedLen 16) (ne $decodedLen 32) -}}
        {{- fail (printf "Invalid APP_KEY: Laravel requires base64 decoded key to be 16 bytes (AES-128) or 32 bytes (AES-256), got %d bytes.\nThis prevents Laravel RuntimeException: 'Unsupported cipher or incorrect key length'.\nGenerate a valid key with: php artisan key:generate --show" $decodedLen) -}}
      {{- end -}}
    {{- else -}}
      {{/* Validate plain text APP_KEY */}}
      {{- if ne (len $appKey) 32 -}}
        {{- fail (printf "Invalid APP_KEY: Laravel requires plain key to be exactly 32 characters for AES-256-CBC, got %d characters.\nThis prevents Laravel RuntimeException: 'Unsupported cipher or incorrect key length'.\nProvide a 32-character key or use base64: prefix format.\nGenerate a valid key with: php artisan key:generate --show" (len $appKey)) -}}
      {{- end -}}
    {{- end -}}
    {{/* Return validated APP_KEY */}}
    {{- .Values.secret.appKey | b64enc -}}
  {{- else if and .Release.IsUpgrade $existingSecret $existingSecret.data -}}
    {{/* Reuse existing secret during upgrade when no new key provided */}}
    {{- index $existingSecret.data "EXIVITY_APP_KEY" -}}
  {{- else -}}
    {{/* Generate secure random 32-character APP_KEY */}}
    {{- randAlphaNum 32 | b64enc -}}
  {{- end -}}
{{- end -}}
