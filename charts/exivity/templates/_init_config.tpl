{{- define "exivity.initConfigContainer" -}}
{{- $appname := .appname -}}
{{- $path := .path -}}
{{- $queue := .queue -}}
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
  volumeMounts:
    - name: config-generated
      mountPath: /exivity/home/system
    - name: config-generator-script
      mountPath: /scripts
      readOnly: true
    - name: postgres-config
      mountPath: /config/postgres
      readOnly: true
    - name: postgres-secret
      mountPath: /secrets/postgres
      readOnly: true
    - name: rabbitmq-config
      mountPath: /config/rabbitmq
      readOnly: true
    - name: rabbitmq-secret
      mountPath: /secrets/rabbitmq
      readOnly: true
{{- end }}

{{- define "exivity.configGeneratedVolume" -}}
- name: config-generated
  emptyDir: {}
- name: config-generator-script
  configMap:
    name: {{ printf "%s-config-generator" (include "exivity.fullname" .) }}
    defaultMode: 0755
- name: postgres-config
  configMap:
    name: {{ printf "%s-postgres-config" (include "exivity.fullname" .) }}
- name: postgres-secret
  secret:
    secretName: {{ printf "%s-postgres-secret" (include "exivity.fullname" .) }}
- name: rabbitmq-config
  configMap:
    name: {{ printf "%s-rabbitmq-config" (include "exivity.fullname" .) }}
- name: rabbitmq-secret
  secret:
    secretName: {{ printf "%s-rabbitmq-secret" (include "exivity.fullname" .) }}
{{- end }}

{{- define "exivity.configGeneratedVolumeMount" -}}
- name: config-generated
  mountPath: /exivity/home/system/config.json
  subPath: config.json
{{- end }}

{{- define "exivity.initPigeonConfigContainer" -}}
- name: generate-config
  image: linuxserver/yq:latest
  command: ["/bin/sh"]
  args: ["/scripts/generate-pigeon-config.sh"]
  volumeMounts:
    - name: config-generated
      mountPath: /exivity/home/system
    - name: config-generator-script
      mountPath: /scripts
      readOnly: true
    - name: postgres-config
      mountPath: /config/postgres
      readOnly: true
    - name: postgres-secret
      mountPath: /secrets/postgres
      readOnly: true
    - name: rabbitmq-config
      mountPath: /config/rabbitmq
      readOnly: true
    - name: rabbitmq-secret
      mountPath: /secrets/rabbitmq
      readOnly: true
{{- end }}
