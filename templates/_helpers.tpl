

{{- define "iocnames" -}}
{{- $list := .Values.epicsConfiguration.iocs }}
{{- $commaSeparatedString := "" }}

{{- range $index, $element := $list }}
  {{- if $element.disable }}
  {{- else }}
  {{- if $element.host }}
    {{- if $element.ca_server_port }}
      {{- $portAsString := int $element.ca_server_port }}

      {{- $commaSeparatedString = printf "%s:%d %s" $element.host $portAsString $commaSeparatedString }}
    {{- else }}
      {{- $commaSeparatedString = printf "%s %s" $element.host $commaSeparatedString }}
    {{- end}}
  {{- else }}
    {{- if $element.ca_server_port }}
      {{- $portAsString := int $element.ca_server_port }}

      {{- $commaSeparatedString = printf "%s.%s.svc:%d %s" $element.name $.Values.namespace $portAsString $commaSeparatedString }}
    {{- else }}
      {{- $commaSeparatedString = printf "%s.%s.svc %s" $element.name $.Values.namespace $commaSeparatedString }}
    {{- end }}
  {{- end }}
  {{- end}}

  {{- if ne $index (sub (len $list) 1) }}
    {{- $commaSeparatedString = printf "%s " $commaSeparatedString }}
  {{- end }} 
{{- end }}

{{- $commaSeparatedString }}
{{- end }}



{{- define "gateway-service" -}}
{{- if hasKey .Values.epicsConfiguration.services "gateway" }}
{{- printf "gateway.%s" .Values.namespace }}
{{- end }}
{{- end }}

{{- define "mysql-service" -}}
{{- if hasKey .Values.epicsConfiguration.services "mysql" }}
{{- printf "mysql.%s" .Values.namespace }}
{{- end }}
{{- end }}


{{- define "archiver-url" -}}
{{- if hasKey .Values.epicsConfiguration.services "archiver" }}
{{- printf "%s-archiver.%s" .Values.beamline .Values.epik8namespace }}
{{- end }}
{{- end }}


{{- define "channelfinder-url" -}}
{{- if hasKey .Values.epicsConfiguration.services "channelfinder" }}
{{- printf "%s-channelfinder.%s" .Values.beamline .Values.epik8namespace }}
{{- end }}
{{- end }}

{{- define "saveandrestore-url" -}}
{{- if hasKey .Values.epicsConfiguration.services "saveandrestore" }}
{{- printf "%s-saveandrestore.%s" .Values.beamline .Values.epik8namespace }}
{{- end }}
{{- end }}

{{- define "console-url" -}}
{{- if hasKey .Values.epicsConfiguration.services "console" }}
{{- printf "%s-console.%s" .Values.beamline .Values.epik8namespace }}
{{- end }}
{{- end }}

{{- define "olog-url" -}}
{{- if hasKey .Values.epicsConfiguration.services "olog" }}
{{- printf "%s-olog.%s" .Values.beamline .Values.epik8namespace }}
{{- end }}
{{- end }}

{{- define "scanserver-url" -}}
{{- if hasKey .Values.epicsConfiguration.services "scanserver" }}
{{- printf "%s-scanserver.%s" .Values.beamline .Values.epik8namespace }}
{{- end }}
{{- end }}


{{- define "notebook-url" -}}
{{- if hasKey .Values.epicsConfiguration.services "notebook" }}
{{- printf "%s-notebook.%s" .Values.beamline .Values.epik8namespace }}
{{- end }}
{{- end }}

{{- define "alarmserver-url" -}}
{{- if hasKey .Values.epicsConfiguration.services "alarmserver" }}
{{- printf "%s-alarmserver.%s" .Values.beamline .Values.epik8namespace }}
{{- end }}
{{- end }}

{{- define "alarmlogger-url" -}}
{{- if hasKey .Values.epicsConfiguration.services "alarmlogger" }}
{{- printf "%s-alarmlogger.%s" .Values.beamline .Values.epik8namespace }}
{{- end }}
{{- end }}

{{- define "allocateIpFromName" -}}
  {{- $name := printf "%s.%s" .Release.Name .Release.Namespace -}}
  {{- $baseIpWithCIDR := .Values.baseIp -}}  # base IP in CIDR notation, e.g., "10.152.182.0/23"
  {{- $startIp := .Values.startIp | int -}}  # Starting IP offset
  {{- $conversion := atoi (adler32sum $name) -}}

  # Split the base IP and range
  {{- $baseIpParts := split "/" $baseIpWithCIDR -}}
  {{- $baseIp := index $baseIpParts 0 -}}   # Base IP without CIDR, e.g., "10.152.182.0"
  {{- $cidrRange := index $baseIpParts 1 | int -}}  # CIDR range, e.g., 23 or 24

  # Convert base IP into octets
  {{- $octets := split "." $baseIp -}}
  {{- $firstOctet := index $octets 0 | int -}}
  {{- $secondOctet := index $octets 1 | int -}}
  {{- $thirdOctet := index $octets 2 | int -}}
  {{- $fourthOctet := index $octets 3 | int -}}

  # Calculate the number of available IPs from the CIDR range
  {{- $ipRange := (2 | mul (sub 32 $cidrRange)) | int -}}  # Number of IPs in the given CIDR range

  # Calculate the IP suffix based on the conversion and the available IP range
  {{- $ipSuffix := add $startIp (mod $conversion $ipRange) -}}

  # Add the calculated suffix to the base IP
  {{- $thirdOctet := add $thirdOctet (div $ipSuffix 256) -}}
  {{- $fourthOctet := mod $ipSuffix 256 -}}

  # Print the resulting IP
  {{- printf "%d.%d.%d.%d" $firstOctet $secondOctet $thirdOctet $fourthOctet -}}
{{- end -}}
