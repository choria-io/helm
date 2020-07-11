{{- define "provisioner.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
