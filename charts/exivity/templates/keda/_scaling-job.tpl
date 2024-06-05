{{- define "exivity.scalingJobSpec" -}}
pollingInterval: 1
triggers:
- type: rabbitmq
  metadata:
      protocol: auto
      mode: QueueLength
      value: "1"
      queueName: "{{ .queueName }}"
  authenticationRef:
      name: {{ include "exivity.fullname" .values }}-keda-trigger-auth-rabbitmq-conn
{{- end -}}
