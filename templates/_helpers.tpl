

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

{{- define "allocateIpFromNames" -}}
  {{- $name := printf "%s.%s" .name .namespace -}}  # Use name and namespace from the parameters

  {{- $baseIpWithCIDR := .baseIp -}}  # base IP in CIDR notation, e.g., "10.152.182.0/23"

  {{- $startIp := .startIp | int -}}  # Starting IP offset
  {{- $conversion := atoi (adler32sum $name) -}}
  {{- $baseIpParts := split "/" $baseIpWithCIDR -}}
  {{- printf "baseIpParts: %s %s %s \n" $baseIpParts (index $baseIpParts "_0") (index $baseIpParts "_1")}}
  

{{- end}}
{{- define "allocateIpFromName" -}}
  {{- $name := printf "%s.%s" .name .namespace -}}
  {{- $baseIpWithCIDR := .baseIp -}}  

  {{- $startIp := .startIp | int -}}  
  {{- $conversion := atoi (adler32sum $name) -}}

  {{- $baseIpParts := split "/" $baseIpWithCIDR -}}
  {{- $baseIp := index $baseIpParts "_0" -}}   
  {{- $cidrRange := index $baseIpParts "_1" | int -}}  

  {{- $octets := split "." $baseIp -}}
  {{- $firstOctet := index $octets "_0" | int -}}
  {{- $secondOctet := index $octets "_1" | int -}}
  {{- $thirdOctet := index $octets "_2" | int -}}
  {{- $fourthOctet := index $octets "_3" | int -}}
  {{- $ipRange := 65536 }}

  {{- if eq $cidrRange 24 }}
    {{- $ipRange = 256 }}
  {{- end }}

  {{- if eq $cidrRange 23 }}
    {{- $ipRange = 512 }}
  {{- end }}

  {{- if eq $cidrRange 22 }}
    {{- $ipRange = 1024 }}
  {{- end }}

  {{- if eq $cidrRange 21 }}
    {{- $ipRange = 2048 }}
  {{- end }}

  {{- if eq $cidrRange 20 }}
    {{- $ipRange = 4096 }}
  {{- end }}

  {{- if eq $cidrRange 19 }}
    {{- $ipRange = 8192 }}
  {{- end }}

  {{- if eq $cidrRange 18 }}
    {{- $ipRange = 16384 }}
  {{- end }}

  {{- if eq $cidrRange 17 }}
    {{- $ipRange = 32768 }}
  {{- end }}
  {{- $ipSuffix := add $startIp (mod $conversion $ipRange) -}}

  {{- $thirdOctet := add $thirdOctet (div $ipSuffix 256) -}}
  {{- $fourthOctet := mod $ipSuffix 256 -}}

  {{- printf "%d.%d.%d.%d" $firstOctet $secondOctet $thirdOctet $fourthOctet -}}
{{- end -}}

