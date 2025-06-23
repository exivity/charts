{{- define "exivity.initPermissionsContainer" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $volumes := .volumes -}}
{{- $svc := index $root.Values.service $component | default dict -}}
{{- $sc := $svc.securityContext | default $root.Values.global.securityContext -}}
{{- $uid := $sc.runAsUser | default 1000 -}}
{{- $gid := $sc.runAsGroup | default 1000 -}}
{{- if .root.Values.storage.permissions.enabled }}
- name: set-volume-permissions
  image: busybox:stable
  securityContext:
    runAsUser: 0
    runAsNonRoot: false
  command: ["/bin/sh", "/scripts/set_ownership.sh"]
  args: ["{{ $uid }}", "{{ $gid }}", "{{ $root.Values.storage.permissions.policy }}"]
  volumeMounts:
    {{- range $vol := $volumes }}
    - name: {{ $vol }}
      mountPath: /mnt/{{ $vol }}
    {{- end }}
    - name: permission-script
      mountPath: /scripts
      readOnly: true
{{- end }}
{{- end }}

{{- define "exivity.initPermissions" -}}
{{- if .root.Values.storage.permissions.enabled }}
initContainers:
{{ include "exivity.initPermissionsContainer" . | nindent 2 }}
{{- end }}
{{- end }}

{{- define "exivity.permissionScriptVolume" -}}
{{- if .Values.storage.permissions.enabled }}
- name: permission-script
  configMap:
    name: permission-script
    defaultMode: 0755
{{- end }}
{{- end }}
