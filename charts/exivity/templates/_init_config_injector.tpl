{{/*
Simple init container that injects secrets into config.json
Replaces placeholders {{DB_USER}}, {{DB_PASSWORD}}, {{MQ_USER}}, {{MQ_PASSWORD}}
Can be used by all deployments
*/}}
{{- define "exivity.initConfigInjector" }}
- name: inject-secrets
  image: {{ include "exivity.image" (set $ "name" "configGenerator") }}
  imagePullPolicy: {{ .Values.service.configGenerator.pullPolicy | default .Values.service.pullPolicy | default "IfNotPresent" }}
  command: ["/bin/sh", "-c"]
  args:
    - |
      set -e
      echo "Injecting secrets into config.json..."
      
      jq --arg db_user "$DB_USER" \
         --arg db_password "$DB_PASSWORD" \
         --arg mq_user "$MQ_USER" \
         --arg mq_password "$MQ_PASSWORD" \
         '.db.parameters.user = $db_user | 
          .db.parameters.password = $db_password | 
          .mq.user = $mq_user | 
          .mq.password = $mq_password' \
         /config-template/config.json > /config/config.json
      
      echo "Config generated successfully"
  env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: {{ include "exivity.fullname" . }}-postgres-secret
          key: POSTGRES_USER
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ include "exivity.fullname" . }}-postgres-secret
          key: POSTGRES_PASSWORD
    - name: MQ_USER
      valueFrom:
        secretKeyRef:
          name: {{ include "exivity.fullname" . }}-rabbitmq-secret
          key: RABBITMQ_USERNAME
    - name: MQ_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ include "exivity.fullname" . }}-rabbitmq-secret
          key: RABBITMQ_PASSWORD
  volumeMounts:
    - name: config-template
      mountPath: /config-template
      readOnly: true
    - name: config-generated
      mountPath: /config
{{- end }}

{{/*
Volume for the config template (ConfigMap with placeholders)
*/}}
{{- define "exivity.configTemplateVolume" }}
- name: config-template
  configMap:
    name: {{ .configMapName }}
{{- end }}

{{/*
Volume for the generated config (emptyDir)
*/}}
{{- define "exivity.configGeneratedVolume" }}
- name: config-generated
  emptyDir: {}
{{- end }}

{{/*
Volume mount for the generated config.json
*/}}
{{- define "exivity.configVolumeMount" }}
- name: config-generated
  mountPath: /exivity/home/system/config.json
  subPath: config.json
{{- end }}
