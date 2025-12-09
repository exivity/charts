{{/*
Shared Postgres and RabbitMQ environment variables
*/}}
{{- define "exivity.dbMqEnvVars" -}}
- name: DB_HOST
  value: {{ .Values.postgresql.host | default (printf "%s-postgresql" (include "exivity.fullname" .)) | quote }}
- name: DB_PORT
  value: {{ .Values.postgresql.port | quote }}
- name: DB_SSLMODE
  value: {{ .Values.postgresql.sslmode | default "disable" | quote }}
- name: DB_NAME
  value: {{ .Values.postgresql.global.postgresql.auth.database | quote }}
- name: MQ_HOST
  value: {{ .Values.rabbitmq.host | default (printf "%s-%s" (include "exivity.fullname" .) (.Values.rabbitmq.nameOverride | default "rabbitmq")) | quote }}
- name: MQ_PORT
  value: {{ .Values.rabbitmq.port | default 5672 | toString | quote }}
- name: MQ_SECURE
  value: {{ .Values.rabbitmq.secure | default false | toString | quote }}
- name: MQ_VHOST
  value: {{ .Values.rabbitmq.vhost | default "/" | quote }}
{{- end }}

------------------------------------

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
{{- $root := .root -}}
- name: generate-config
  image: linuxserver/yq:latest
  command: ["/bin/sh"]
  args: ["/scripts/generate-config.sh"]
  env:
    {{- if $appname }}
    - name: APPNAME
      value: "{{ $appname }}"
    - name: PATH_VAR
      value: "{{ $path }}"
    - name: QUEUE
      value: "{{ $queue }}"
    {{- end }}
    {{- include "exivity.dbMqEnvVars" $root | nindent 4 }}
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

------------------------------------

{{- define "exivity.initPigeonConfigContainer" -}}
- name: generate-config
  image: linuxserver/yq:latest
  command: ["/bin/sh"]
  args: ["/scripts/generate-pigeon-config.sh"]
  env:
    {{- include "exivity.dbMqEnvVars" . | nindent 4 }}
  volumeMounts:
    {{- include "exivity.configGeneratorVolumeMounts" . | nindent 4 }}
{{- end }}
