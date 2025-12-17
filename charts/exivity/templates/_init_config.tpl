{{- define "exivity.initConfigContainer" -}}
{{- $appname := .appname -}}
{{- $path := .path -}}
{{- $queue := .queue -}}
- name: generate-config
  image: {{ printf "%s/%s:%s" .root.Values.configGenerator.registry .root.Values.configGenerator.repository .root.Values.configGenerator.tag }}
  imagePullPolicy: {{ .root.Values.configGenerator.pullPolicy }}
  command: ["/bin/sh", "-c"]
  args:
    - |
      jq -n \
        --arg db_user "$(DB_USER)" \
        --arg db_password "$(DB_PASSWORD)" \
        --arg mq_user "$(MQ_USER)" \
        --arg mq_password "$(MQ_PASSWORD)" \
        '{
          "db": {
            "driver": "postgres",
            "parameters": {
              "host": "{{ .root.Values.postgresql.host | default (printf "%s-postgresql" (include "exivity.fullname" .root)) }}",
              "port": {{ .root.Values.postgresql.port }},
              "sslmode": "{{ .root.Values.postgresql.sslmode }}",
              "dbname": "{{ .root.Values.postgresql.global.postgresql.auth.database }}",
              "user": $db_user,
              "password": $db_password,
              "connect_timeout": 10
            }
          },
          "mq": {
            "servers": [{
              "host": "{{ if .root.Values.rabbitmq.host }}{{ .root.Values.rabbitmq.host }}{{ else if .root.Values.rabbitmq.nameOverride }}{{ printf "%s-%s" (include "exivity.fullname" .root) .root.Values.rabbitmq.nameOverride }}{{ else }}{{ printf "%s-rabbitmq" (include "exivity.fullname" .root) }}{{ end }}",
              "port": {{ .root.Values.rabbitmq.port }},
              "secure": {{ .root.Values.rabbitmq.secure }}
            }],
            "user": $mq_user,
            "password": $mq_password,
            "vhost": "{{ .root.Values.rabbitmq.vhost }}",
            "redialPeriod": 5
          },
          "chronos": {
            "TTL": 60
          },
          "griffon": {
            "TTL": 10
          }
          {{- if $appname }},
          "merlin": {
            "reservedCPU": 0,
            "programs": {
              "{{ $appname }}": {
                "component": "{{ $appname }}",
                "path": "{{ $path }}",
                "queue": "{{ $queue }}"
                {{- if eq $appname "use" }},
                "params": "${params}"
                {{- end }},
                "CPU": 0,
                "RAM": 0
              }
            }
          }
          {{- end }}
        }' > /exivity/home/system/config.json
  env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-postgres-secret" (include "exivity.fullname" .root) }}
          key: POSTGRES_USER
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-postgres-secret" (include "exivity.fullname" .root) }}
          key: POSTGRES_PASSWORD
    - name: MQ_USER
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-rabbitmq-secret" (include "exivity.fullname" .root) }}
          key: RABBITMQ_USERNAME
    - name: MQ_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-rabbitmq-secret" (include "exivity.fullname" .root) }}
          key: RABBITMQ_PASSWORD
  volumeMounts:
    - name: config-generated
      mountPath: /exivity/home/system
{{- end }}

------------------------------------

{{- define "exivity.initPigeonConfigContainer" -}}
- name: generate-config
  image: {{ printf "%s/%s:%s" .Values.configGenerator.registry .Values.configGenerator.repository .Values.configGenerator.tag }}
  imagePullPolicy: {{ .Values.configGenerator.pullPolicy }}
  command: ["/bin/sh", "-c"]
  args:
    - |
      jq -n \
        --arg db_user "$(DB_USER)" \
        --arg db_password "$(DB_PASSWORD)" \
        --arg mq_user "$(MQ_USER)" \
        --arg mq_password "$(MQ_PASSWORD)" \
        '{
          "db": {
            "driver": "postgres",
            "parameters": {
              "host": "{{ .Values.postgresql.host | default (printf "%s-postgresql" (include "exivity.fullname" .)) }}",
              "port": {{ .Values.postgresql.port }},
              "sslmode": "{{ .Values.postgresql.sslmode }}",
              "dbname": "{{ .Values.postgresql.global.postgresql.auth.database }}",
              "user": $db_user,
              "password": $db_password,
              "connect_timeout": 10
            }
          },
          "mq": {
            "servers": [{
              "host": "{{ if .Values.rabbitmq.host }}{{ .Values.rabbitmq.host }}{{ else if .Values.rabbitmq.nameOverride }}{{ printf "%s-%s" (include "exivity.fullname" .) .Values.rabbitmq.nameOverride }}{{ else }}{{ printf "%s-rabbitmq" (include "exivity.fullname" .) }}{{ end }}",
              "port": {{ .Values.rabbitmq.port }},
              "secure": {{ .Values.rabbitmq.secure }}
            }],
            "user": $mq_user,
            "password": $mq_password,
            "vhost": "{{ .Values.rabbitmq.vhost }}",
            "redialPeriod": 5
          },
          "merlin": {
            "reservedCPU": 1,
            "heartbeatPeriod": 5,
            "programs": {
              "pigeon": {
                "path": "/usr/bin/php",
                "queue": "PIGEON",
                "CPU": 0,
                "RAM": 0
              },
              "report_published": {
                "CPU": 0.25,
                "RAM": 250,
                "component": "pigeon",
                "params": "common/pigeon/pigeon.phar event:post report_published `${payload}`",
                "path": "/usr/bin/php",
                "queue": "REPORT_PUBLISHED",
                "topic": "evt.report_published.proximity.#"
              },
              "workflow_ended": {
                "CPU": 0.25,
                "RAM": 250,
                "component": "pigeon",
                "params": "common/pigeon/pigeon.phar event:post workflow_ended `${payload}`",
                "path": "/usr/bin/php",
                "queue": "WORKFLOW_EVENT",
                "topic": "evt.workflow_status.griffon.#"
              }
            }
          }
        }' > /exivity/home/system/config.json
  env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-postgres-secret" (include "exivity.fullname" .) }}
          key: POSTGRES_USER
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-postgres-secret" (include "exivity.fullname" .) }}
          key: POSTGRES_PASSWORD
    - name: MQ_USER
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-rabbitmq-secret" (include "exivity.fullname" .) }}
          key: RABBITMQ_USERNAME
    - name: MQ_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ printf "%s-rabbitmq-secret" (include "exivity.fullname" .) }}
          key: RABBITMQ_PASSWORD
  volumeMounts:
    - name: config-generated
      mountPath: /exivity/home/system
{{- end }}

------------------------------------

{{- define "exivity.configVolume" -}}
- name: config-generated
  emptyDir: {}
{{- end }}

------------------------------------

{{- define "exivity.configVolumeMount" -}}
- name: config-generated
  mountPath: /exivity/home/system/config.json
  subPath: config.json
{{- end }}
