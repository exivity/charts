{{/*
Shared volume mounts for config generation
*/}}
{{- define "exivity.configGeneratorVolumeMounts" -}}
- name: config-generated
  mountPath: /exivity/home/system
- name: config-generator-script
  mountPath: /scripts
  readOnly: true
- name: postgres-secret
  mountPath: /secrets/postgres
  readOnly: true
- name: rabbitmq-secret
  mountPath: /secrets/rabbitmq
  readOnly: true
{{- end }}

------------------------------------

{{- define "exivity.initConfigContainer" -}}
{{- $appname := .appname -}}
{{- $path := .path -}}
{{- $queue := .queue -}}
- name: generate-config
  image: linuxserver/yq:latest
  command: ["/bin/sh"]
  args: ["/scripts/generate-config.sh"]
  {{- if $appname }}
  env:
    - name: APPNAME
      value: "{{ $appname }}"
    - name: PATH_VAR
      value: "{{ $path }}"
    - name: QUEUE
      value: "{{ $queue }}"
  {{- end }}
  volumeMounts:
    {{- include "exivity.configGeneratorVolumeMounts" . | nindent 4 }}
{{- end }}

------------------------------------

{{- define "exivity.initPigeonConfigContainer" -}}
- name: generate-config
  image: linuxserver/yq:latest
  command: ["/bin/sh"]
  args: ["/scripts/generate-pigeon-config.sh"]
  volumeMounts:
    {{- include "exivity.configGeneratorVolumeMounts" . | nindent 4 }}
{{- end }}

------------------------------------

{{- define "exivity.configGeneratedVolume" -}}
- name: config-generated
  emptyDir: {}
- name: config-generator-script
  configMap:
    name: {{ printf "%s-config-generator" (include "exivity.fullname" .) }}
    defaultMode: 0755
- name: postgres-secret
  secret:
    secretName: {{ printf "%s-postgres-secret" (include "exivity.fullname" .) }}
- name: rabbitmq-secret
  secret:
    secretName: {{ printf "%s-rabbitmq-secret" (include "exivity.fullname" .) }}
{{- end }}

------------------------------------

{{- define "exivity.configGeneratedVolumeMount" -}}
- name: config-generated
  mountPath: /exivity/home/system/config.json
  subPath: config.json
{{- end }}
