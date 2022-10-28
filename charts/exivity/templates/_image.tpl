{{- define "exivity.image" -}}
{{ (index .Values.service .name ).registry | default .Values.service.registry -}}
/
{{- (index .Values.service .name ).repository -}}
:
{{- (index .Values.service .name ).tag | default .Values.service.tag | default (printf "exivity-%s" (.Chart.Version)) }}
{{- end -}}
