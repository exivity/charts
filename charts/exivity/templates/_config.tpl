# Generate a configmap to be mounted into any container using Merlin to run
# part of the applications. Takes a dict as an arg;
# Pass the raw helm `.Values`,
# for the benefit of Merlin the following three entries can also be passed:
# `appname`, `path` to the executable, and `queue` to sub on.
#
# E.g.
#
# {{- include "exivity.config" (dict "Values" .Values "appname" "edify" "path" "/bin/edify" "queue" "REPORT") }}
#
{{- define "exivity.config" }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-{{ .appname | default "default" }}
data:
  config.json: |-
    {
      "chronos": {
        "heartbeatPeriod": 5,
        "TTL": 60
      },
      "db": {
        "driver": "postgres",
        "parameters": {
          "host": "{{ .Values.postgresql.fullnameOverride }}",
          "port": 5432,
          "dbname": "{{ .Values.postgresql.auth.database }}",
          "user": "{{ .Values.postgresql.auth.username }}",
          "password": "{{ .Values.postgresql.auth.password }}",
          "connect_timeout": 10,
          "sslmode": "disable"
        }
      },
      "griffon": {
        "heartbeatPeriod": 5,
        "TTL": 10
      },
      "mq": {
        "servers": [
          {
            "host": "{{ .Values.rabbitmq.host }}",
            "port": {{ .Values.rabbitmq.port }},
            "secure": false
          }
        ],
        "user": "{{ .Values.rabbitmq.user }}",
        "password": "{{ .Values.rabbitmq.password }}",
        "vhost": "/",
        "redialPeriod": 5
      {{ if .appname }}
      },
      "merlin": {
        "reservedCPU": 0,
        "heartbeatPeriod": 5,
        "programs": {
          "{{ .appname }}": {
            "component": "{{ .appname }}",
            "path": "{{ .path }}",
            "queue": "{{ .queue}}",
            "CPU": 0,
            {{- if eq .appname "use" }}
            "params": "${params}",
            {{- end }}
            "RAM": 0
          }
        }
      {{ end }}
      }
    }
{{- end }}
