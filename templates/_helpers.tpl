
{{- define "archiver-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.archiver  .Values.epik8namespace }}
{{- end }}

{{- define "channelfinder-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.channelfinder  .Values.epik8namespace }}
{{- end }}

{{- define "saveandrestore-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.saveandrestore .Values.epik8namespace }}
{{- end }}

{{- define "console-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.console .Values.epik8namespace }}
{{- end }}


{{- define "olog-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.olog .Values.epik8namespace }}
{{- end }}

{{- define "scanserver-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.scanserver .Values.epik8namespace }}
{{- end }}


{{- define "jupyter-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.jupyter .Values.epik8namespace }}
{{- end }}


{{- define "alarmserver-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.epicsConfiguration.alarmserver .Values.epik8namespace }}
{{- end }}
