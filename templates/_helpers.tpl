
{{- define "archiver-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.services.archiver.name  .Values.epik8namespace }}
{{- end }}

{{- define "channelfinder-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.services.channelfinder.name  .Values.epik8namespace }}
{{- end }}

{{- define "saveandrestore-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.services.saveandrestore.name .Values.epik8namespace }}
{{- end }}

{{- define "iocnames" -}}
{{- $list := .Values.epicsConfiguration.iocs }}
{{- $commaSeparatedString := "" }}

{{- range $index,$element:=$list }}
  {{- $commaSeparatedString = printf "%s%s" $element.name $commaSeparatedString }}
  {{- if ne $index (sub (len $list) 1) }}
    {{- $commaSeparatedString = printf "%s " $commaSeparatedString }}
  {{- end }} 
{{- end }}
{{- $commaSeparatedString }}
{{- end }}
{{- define "console-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.services.console.name .Values.epik8namespace }}
{{- end }}


{{- define "olog-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.services.olog.name .Values.epik8namespace }}
{{- end }}

{{- define "scanserver-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.services.scanserver.name .Values.epik8namespace }}
{{- end }}


{{- define "jupyter-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.services.jupyter.name .Values.epik8namespace }}
{{- end }}


{{- define "alarmserver-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.services.alarmserver.name .Values.epik8namespace }}
{{- end }}

{{- define "gateway-service" -}}
{{ .Values.epicsConfiguration.services.gateway.name }}.{{ .Values.namespace }}.svc.cluster.local 
{{- end }}

{{- define "mysql-service" -}}
{{ .Values.epicsConfiguration.services.mysql.name }}.{{ .Values.namespace }}.svc.cluster.local 
{{- end }}