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
          "host": "{{ .Values.database.host }}",
          "port": {{ .Values.database.port }},
          "dbname": "{{ .Values.database.dbname }}",
          "user": "{{ .Values.database.username }}",
          "password": "{{ .Values.database.password }}",
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
            "host": "{{ .Values.rabbitMQ.host }}",
            "port": {{ .Values.rabbitMQ.port }},
            "secure": false
          }
        ],
        "user": "{{ .Values.rabbitMQ.user }}",
        "password": "{{ .Values.rabbitMQ.password }}",
        "vhost": "/",
        "redialPeriod": 5
      "{{ if .appname }}"
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
            "RAM": 0
          }
        }
      "{{ end }}"
      }
    }
{{- end }}
