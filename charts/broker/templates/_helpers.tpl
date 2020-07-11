{{- define "broker.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "stream.fullname" -}}
{{- printf "%s-%s-stream" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "broker.peers" -}}
{{- $count := .Values.broker.clusterSize | int -}}
{{- $last := sub $count 1 -}}
{{- $name := include "broker.fullname" . -}}
  {{- range $i, $e := until $count -}}
    {{- if eq $last $i -}}
      {{- printf "nats://%s-%d.%s-ss.%s.svc.cluster.local:5222" $name $i $name  $.Release.Namespace -}}
    {{- else -}}
      {{- printf "nats://%s-%d.%s-ss.%s.svc.cluster.local:5222," $name  $i $name $.Release.Namespace -}}
    {{- end -}}
  {{- end -}}
{{- end }}
