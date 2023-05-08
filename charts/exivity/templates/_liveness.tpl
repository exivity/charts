{{- define "exivity.nfs-liveness" }}
livenessProbe:
  exec:
    command:
      - sh
      - -c
      - list=$(df 2>&1 | grep -i 'Stale file handle'); [ ${#list} -ne 0 ] && exit 1 || exit 0
  initialDelaySeconds: 10
  periodSeconds: 20
  timeoutSeconds: 2
  failureThreshold: 2
{{- end }}