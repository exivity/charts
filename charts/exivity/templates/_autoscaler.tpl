{{/*
# Generate an autoscaler for the service.
# Pass the service autoscaler options as the parameter
#
# E.g.
# {{- include "exivity.autoscaler" (set $ "name" "glass") }}
*/}}
{{- define "exivity.autoscaler" }}
{{- if (index .Values.service .name).autoscaling }}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ printf "%s-autoscaler-%s" ( include "exivity.fullname" $ ) (kebabcase .name) }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ printf "%s-%s" ( include "exivity.fullname" $ ) (kebabcase .name) }}
  minReplicas: {{ (index .Values.service .name).autoscaling.minReplicas | default 1 }}
  maxReplicas: {{ (index .Values.service .name).autoscaling.maxReplicas | default 5 }}
  metrics:
  {{- if (index .Values.service .name).autoscaling.averageCPUUtilization }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ (index .Values.service .name).autoscaling.averageCPUUtilization }}
  {{- end}}
  {{- if (index .Values.service .name).autoscaling.averageMemoryUtilization }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ (index .Values.service .name).autoscaling.averageMemoryUtilization }}
  {{- end}}
  {{- if (index .Values.service .name).autoscaling.averageMemoryValue }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ (index .Values.service .name).autoscaling.averageMemoryValue }}
  {{- end}}
  {{- if and (not (index .Values.service .name).autoscaling.averageMemoryValue) (not (index .Values.service .name).autoscaling.averageMemoryUtilization) (not (index .Values.service .name).autoscaling.averageCPUUtilization) }}
    []
  {{- end}}
{{- end }}
{{- end }}
