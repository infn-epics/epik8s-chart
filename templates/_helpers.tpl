
{{- define "archiver-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.archiver  .Values.epik8namespace }}
{{- end }}

{{- define "channelfinder-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.channelFinder  .Values.epik8namespace }}
{{- end }}

{{- define "saveandrestore-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.saveandrestore .Values.epik8namespace }}
{{- end }}

{{- define "console-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.console .Values.epik8namespace }}
{{- end }}


{{- define "olog-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.olog .Values.epik8namespace }}
{{- end }}

{{- define "scanserver-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.scanserver .Values.epik8namespace }}
{{- end }}


{{- define "jupyter-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.jupyter .Values.epik8namespace }}
{{- end }}


{{- define "alarmserver-url" -}}
{{- printf "%s-%s.%s" .Values.beamline .Values.alarmserver .Values.epik8namespace }}
{{- end }}
