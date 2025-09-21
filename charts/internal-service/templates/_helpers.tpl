{{- define "internal-service.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "internal-service.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "internal-service.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "internal-service.labels" -}}
app.kubernetes.io/name: {{ include "internal-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/component: web
{{- end }}
