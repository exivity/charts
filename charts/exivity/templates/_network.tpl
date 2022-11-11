{{- define "exivity.network.internetIpBlock" }}
cidr: 0.0.0.0/0
except:
  - 10.0.0.0/8
  - 192.168.0.0/16
  - 172.16.0.0/20
{{- end }}

{{- define "exivity.network.rabbitmqPorts" }}
- port:     5672
  protocol: TCP
{{- end }}

{{- define "exivity.network.rabbitmqLabels" }}
app.kubernetes.io/name:     rabbitmq
app.kubernetes.io/instance: {{ include "exivity.fullname" $ }}
{{- end }}

{{- define "exivity.network.databasePorts" }}
- port:     53
  protocol: UDP
- port:     53
  protocol: TCP
{{- end }}

{{- define "exivity.network.databaseLabels" }}
app.kubernetes.io/name:     postgresql
app.kubernetes.io/instance: {{ include "exivity.fullname" $ }}
{{- end }}
