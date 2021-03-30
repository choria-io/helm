{{- define "tally.fullname" -}}
{{- printf "%s-%s-%s" .Release.Name .Chart.Name .Values.tally.component | trunc 63 | trimSuffix "-" -}}
{{- end -}}
