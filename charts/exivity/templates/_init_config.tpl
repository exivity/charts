{{- define "exivity.initConfigContainer" -}}
{{- $root := .root -}}
{{- $appname := .appname -}}
{{- $path := .path -}}
{{- $queue := .queue -}}
- name: generate-config
  image: busybox:stable
  command: ["/bin/sh", "-c"]
  args:
    - |
      set -eu
      tmp_config="/tmp/exivity-config.json"
      cat <<'EOF' > "$tmp_config"
      {
        "db": {
          "driver": "postgres",
          "parameters": {
            "host":            "{{ $root.Values.postgresql.host | default (printf "%s-postgresql" (include "exivity.fullname" $root)) }}",
            "port":            {{ $root.Values.postgresql.port | default 5432 }},
            "sslmode":         "{{ $root.Values.postgresql.sslmode | default "disable" }}",
            "dbname":          "{{ $root.Values.postgresql.global.postgresql.auth.database }}",
            "user":            "{{ $root.Values.postgresql.global.postgresql.auth.username }}",
            "password":        "{{ $root.Values.postgresql.global.postgresql.auth.password }}",
            "connect_timeout": 10
          }
        },
        "mq": {
            "servers": [
                {
                    "host":   "{{ $root.Values.rabbitmq.host | default (printf "%s-rabbitmq" (include "exivity.fullname" $root)) }}",
                    "port":   {{ $root.Values.rabbitmq.port | default 5672 }},
                    "secure": {{ $root.Values.rabbitmq.secure | default false }}
                }
            ],
            "user":         "{{ $root.Values.rabbitmq.auth.username }}",
            "password":     "{{ $root.Values.rabbitmq.auth.password }}",
            "vhost":        "{{ $root.Values.rabbitmq.vhost | default "/" }}",
            "redialPeriod": 5
        },
        "chronos": {
          "TTL": 60
        },
        "griffon": {
          "TTL": 10
        }{{- if $appname }},
        "merlin": {
          "reservedCPU": 0,
          "programs": {
            "{{ $appname }}": {
              "component": "{{ $appname }}",
              "path": "{{ $path }}",
              "queue": "{{ $queue }}",
              "CPU": 0,
              {{- if eq $appname "use" }}
              "params": "${params}",
              {{- end }}
              "RAM": 0
            }
          }
        }
        {{- end }}
      }
      EOF
      cp "$tmp_config" /exivity/home/system/config.json
  volumeMounts:
    - name: config-generated
      mountPath: /exivity/home/system
{{- end }}

{{- define "exivity.configGeneratedVolume" -}}
- name: config-generated
  emptyDir: {}
{{- end }}

{{- define "exivity.configGeneratedVolumeMount" -}}
- name: config-generated
  mountPath: /exivity/home/system/config.json
  subPath: config.json
{{- end }}

{{/*
Init container for pigeon's special config (with multiple merlin programs).
*/}}
{{- define "exivity.initPigeonConfigContainer" -}}
{{- $root := . -}}
- name: generate-config
  image: busybox:stable
  command: ["/bin/sh", "-c"]
  args:
    - |
      set -eu
      tmp_config="/tmp/exivity-config.json"
      cat <<'EOF' > "$tmp_config"
      {
        "db": {
          "driver": "postgres",
          "parameters": {
            "host":            "{{ $root.Values.postgresql.host | default (printf "%s-postgresql" (include "exivity.fullname" $root)) }}",
            "port":            {{ $root.Values.postgresql.port | default 5432 }},
            "sslmode":         "{{ $root.Values.postgresql.sslmode | default "disable" }}",
            "dbname":          "{{ $root.Values.postgresql.global.postgresql.auth.database }}",
            "user":            "{{ $root.Values.postgresql.global.postgresql.auth.username }}",
            "password":        "{{ $root.Values.postgresql.global.postgresql.auth.password }}",
            "connect_timeout": 10
          }
        },
        "mq": {
            "servers": [
                {
                    "host":   "{{ $root.Values.rabbitmq.host | default (printf "%s-rabbitmq" (include "exivity.fullname" $root)) }}",
                    "port":   {{ $root.Values.rabbitmq.port | default 5672 }},
                    "secure": {{ $root.Values.rabbitmq.secure | default false }}
                }
            ],
            "user":         "{{ $root.Values.rabbitmq.auth.username }}",
            "password":     "{{ $root.Values.rabbitmq.auth.password }}",
            "vhost":        "{{ $root.Values.rabbitmq.vhost | default "/" }}",
            "redialPeriod": 5
        },
        "merlin": {
          "reservedCPU":     1,
          "heartbeatPeriod": 5,
          "programs": {
            "pigeon": {
              "path":  "/usr/bin/php",
              "queue": "PIGEON",
              "CPU":   0,
              "RAM":   0
            },
            "workflow_ended": {
              "component": "pigeon",
              "path":      "/usr/bin/php",
              "queue":     "WORKFLOW_EVENT",
              "topic":     "evt.workflow_status.griffon.#",
              "params":    "common/pigeon/pigeon.phar event:post workflow_ended `${payload}`",
              "CPU":       0.25,
              "RAM":       250
            },
            "report_published": {
              "component": "pigeon",
              "path":      "/usr/bin/php",
              "queue":     "REPORT_PUBLISHED",
              "topic":     "evt.report_published.proximity.#",
              "params":    "common/pigeon/pigeon.phar event:post report_published `${payload}`",
              "CPU":       0.25,
              "RAM":       250
            }
          }
        }
      }
      EOF
      cp "$tmp_config" /exivity/home/system/config.json
  volumeMounts:
    - name: config-generated
      mountPath: /exivity/home/system
{{- end }}
