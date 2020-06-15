{{- define "tally.fullname" -}}
{{- printf "%s-%s" .Release.Name .Values.tally.component | trunc 63 | trimSuffix "-" -}}
{{- end -}}
