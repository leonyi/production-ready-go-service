{{- define "coolkit.name" -}}
coolkit
{{- end }}

{{- define "coolkit.labels" -}}
app.kubernetes.io/name: {{ include "coolkit.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
