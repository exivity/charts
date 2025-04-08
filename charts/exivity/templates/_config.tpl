{{/*
# Generate a configmap to be mounted into any container using Merlin to run
# part of the applications. Takes a dict as an arg;
# Pass the raw helm `.Values`,
# for the benefit of Merlin the following three entries can also be passed:
# `appname`, `path` to the executable, and `queue` to sub on.
#
# E.g.
# {{- include "exivity.config" (dict "appname" "edify" "path" "/bin/edify" "queue" "REPORT") }}
*/}}
{{- define "exivity.config" }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "exivity.fullname" $ -}}-config-{{- $.data.appname | default "shared" }}
  labels:
    app.kubernetes.io/component: {{ $.data.appname | default "shared" }}
    {{- include "exivity.labels" $ | indent 4 }}
data:
  config.json: |-
    {
      "db": {
        "driver": "postgres",
        "parameters": {
          "host":            {{ $.Values.postgresql.host | default (printf "%s-postgresql" (include "exivity.fullname" $ )) | quote }},
          "port":            {{ $.Values.postgresql.port | default 5432 }},
          "sslmode":         {{ $.Values.postgresql.sslmode | default "disable" | quote }},
          "dbname":          {{ $.Values.postgresql.global.postgresql.auth.database | quote }},
          "user":            {{ $.Values.postgresql.global.postgresql.auth.username | quote }},
          "password":        {{ $.Values.postgresql.global.postgresql.auth.password | quote }},
          "connect_timeout": 10
        }
      },
      "mq": {
          "servers": [
              {
                  "host":   {{ $.Values.rabbitmq.host | default (printf "%s-rabbitmq" (include "exivity.fullname" $ )) | quote }},
                  "port":   {{ $.Values.rabbitmq.port | default 5672 }},
                  "secure": {{ $.Values.rabbitmq.secure | default false }}
              }
          ],
          "user":         {{ $.Values.rabbitmq.auth.username | quote }},
          "password":     {{ $.Values.rabbitmq.auth.password | quote }},
          "vhost":        {{ $.Values.rabbitmq.vhost | default "/" | quote }},
          "redialPeriod": 5
      },
      "chronos": {
        "TTL": 60
      },
      "griffon": {
        "TTL": 10
      {{ if $.data.appname }}
      },
      "merlin": {
        "reservedCPU": 0,
        "programs": {
          "{{ $.data.appname }}": {
            "component": "{{ $.data.appname }}",
            "path": "{{ $.data.path }}",
            "queue": "{{ $.data.queue}}",
            "CPU": 0,
            {{- if eq $.data.appname "use" }}
            "params": "${params}",
            {{- end }}
            "RAM": 0
          }
        }
      {{ end }}
      }
    }
{{- end }}
