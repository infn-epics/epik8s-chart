
{{- define "pvaiocnames" -}}
{{- $list := .Values.epicsConfiguration.iocs }}
{{- $commaSeparatedString := "" }}

{{- range $index, $element := $list }}
  {{- if and (not $element.disable) $element.pva }}
    {{- if $element.host }}
      {{- if $element.pva_server_port }}
        {{- $portAsString := int $element.pva_server_port }}
        {{- $commaSeparatedString = printf "%s %s:%d" $commaSeparatedString $element.host $portAsString }}
      {{- else }}
        {{- $commaSeparatedString = printf "%s %s" $commaSeparatedString $element.host }}
      {{- end }}
    {{- else }}
      {{- if $element.pva_server_port }}
        {{- $portAsString := int $element.pva_server_port }}
        {{- $commaSeparatedString = printf "%s %s.%s.svc:%d" $commaSeparatedString $element.name $.Values.namespace $portAsString }}
      {{- else }}
        {{- $commaSeparatedString = printf "%s %s.%s.svc" $commaSeparatedString $element.name $.Values.namespace }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{- trim $commaSeparatedString -}}
{{- end }}


{{- define "gateway-service" -}}
{{- if hasKey .Values.epicsConfiguration.services "gateway" }}
{{- printf "gateway.%s.svc" .Values.namespace }}
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


  {{- $totalIps := 1 }}
  {{- $loopcnt:= sub 32 $cidrRange -}}
  {{- range $i,$k := until ($loopcnt | int) }}
    {{- $totalIps = mul $totalIps 2 }}
  {{- end }}

  {{- $ipSuffix := add $startIp (mod $conversion $totalIps) -}}

  {{- $secondOctet := add $secondOctet (div $ipSuffix 65536) -}}
  {{- $ipSuffix = mod $ipSuffix 65536 -}}
  {{- $thirdOctet := add $thirdOctet (div $ipSuffix 256) -}}
  {{- $fourthOctet := mod $ipSuffix 256 -}}

  {{- if gt $fourthOctet 255 }}
    {{- $fourthOctet = mod $fourthOctet 256 -}}
  {{- end }}
  {{- if gt $thirdOctet 255 }}
    {{- $thirdOctet = mod $thirdOctet 256 -}}
    {{- $secondOctet = add $secondOctet 1 -}}
  {{- end }}
  {{- if gt $secondOctet 255 }}
    {{- $secondOctet = mod $secondOctet 256 -}}
  {{- end }}

  {{- printf "%d.%d.%d.%d" $firstOctet $secondOctet $thirdOctet $fourthOctet -}}
{{- end -}}


{{- define "allocateIpFromNames" -}}
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

  {{- $totalIps := 1 }}
  {{- $loopcnt:= sub 32 $cidrRange -}}
  {{- range $i,$k := until ($loopcnt | int) }}
    {{- $totalIps = mul $totalIps 2 }}
  {{- end }}
  {{- printf "CIDR %d IPs %d" $cidrRange $totalIps -}}


{{- end -}}


{{- define "iocnames" -}}
{{- $list := .Values.epicsConfiguration.iocs }}
{{- $commaSeparatedString := "" }}

{{- range $index, $element := $list }}
  {{- $staticip := include "allocateIpFromName" (dict "name" $element.name "namespace" $.Values.namespace "baseIp" $.Values.staticIpBase "startIp" $.Values.staticIpStart) -}}  {{- if $element.disable }}
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
      {{- $commaSeparatedString = printf "%s %s" $staticip $commaSeparatedString }}
    {{- end }}
  {{- end }}
  {{- end}}

  {{- if ne $index (sub (len $list) 1) }}
    {{- $commaSeparatedString = printf "%s " $commaSeparatedString }}
  {{- end }} 
{{- end }}

{{- trim $commaSeparatedString }}
{{- end }}