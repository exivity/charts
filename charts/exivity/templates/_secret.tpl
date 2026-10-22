{{/* Check if a value is a secret reference. */}}

{{- define "exivity.isSecretRef" -}}
{{- if kindIs "map" . -}}
  {{- if and .secretName .key -}}
true
  {{- end -}}
{{- end -}}
{{- end -}}

------------------------------------------

{{/* If the value is a secretRef, returns the referenced secret name. */}}

{{- define "exivity.secretRefName" -}}
{{- $value := .value -}}
{{- $defaultName := .defaultName -}}
{{- if kindIs "map" $value -}}
  {{- if and $value.secretName $value.key -}}
    {{- $value.secretName -}}
  {{- else -}}
    {{- $defaultName -}}
  {{- end -}}
{{- else -}}
  {{- $defaultName -}}
{{- end -}}
{{- end -}}

------------------------------------------

{{/* If the value is a secretRef, returns the key. */}}

{{- define "exivity.secretRefKey" -}}
{{- $value := .value -}}
{{- $defaultKey := .defaultKey -}}
{{- if kindIs "map" $value -}}
  {{- if and $value.secretName $value.key -}}
    {{- $value.key -}}
  {{- else -}}
    {{- $defaultKey -}}
  {{- end -}}
{{- else -}}
  {{- $defaultKey -}}
{{- end -}}
{{- end -}}
