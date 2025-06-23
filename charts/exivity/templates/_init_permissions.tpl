{{- define "exivity.initPermissions" -}}
{{- $root := .root -}}
{{- $component := .component -}}
{{- $volumes := .volumes -}}
{{- if $root.Values.storage.permissions.enabled }}
{{- $svc := index $root.Values.service $component | default dict -}}
{{- $sc := $svc.securityContext | default $root.Values.global.securityContext -}}
{{- $uid := $sc.runAsUser | default 1000 -}}
{{- $gid := $sc.runAsGroup | default 1000 -}}
initContainers:
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
