{{- define "pvaiocnames" -}}
{{- $list := .iocs }}
{{- $domain := printf "%s" .domain}}
{{- $defaults := .defaults }}
{{- $softiocs := .softiocs }}

{{- $commaSeparatedString := "" }}

{{- range $index, $element := $list }}
  {{- $ioc := $element }}
  {{- $pva := true }}
  {{- if $defaults }}
    {{- $tmpl := $element.template | default $element.devtype | default "" }}
    {{- if and $tmpl (hasKey $defaults $tmpl) }}
      {{- $defMap := index $defaults $tmpl }}
      {{- $ioc = mustMergeOverwrite (deepCopy $defMap) $element }}
      {{- if hasKey $defMap "pva" }}
        {{- $pva = index $defMap "pva" }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if hasKey $element "pva" }}
    {{- $pva = $element.pva }}
  {{- end }}

  {{- if and (not $ioc.disable) $pva }}
    {{- if $ioc.host }}
      {{- $ips := 0 }}
      {{- if $ioc.networks }}
      {{- range $ioc.networks}}
        {{- if .ip }}
            {{- $commaSeparatedString = printf "%s %s" .ip $commaSeparatedString}}
            {{- $ips := 1 }}

        {{- end}}
      {{- end}}
      {{- else }}
      {{- if $ioc.pva_server_port }}
        {{- $portAsString := int $ioc.pva_server_port }}
        {{- $commaSeparatedString = printf "%s:%d %s" $ioc.host $portAsString $commaSeparatedString }}
      {{- else }}
        {{- $commaSeparatedString = printf "%s %s" $ioc.host $commaSeparatedString }}
      {{- end }}
      {{- end }}
    {{- else }}
      {{- if $ioc.pva_server_port }}
        {{- $portAsString := int $ioc.pva_server_port }}
          {{- $commaSeparatedString = printf "%s.%s.svc:%d %s" ($ioc.name | lower) $domain $portAsString $commaSeparatedString }}
      {{- else }}
        {{- $commaSeparatedString = printf "%s.%s.svc %s" ($ioc.name | lower) $domain $commaSeparatedString }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{- range $index, $softioc := $softiocs }}
  {{- if not $softioc.disable }}
    {{- if $softioc.pva_server_port }}
      {{- $portAsString := int $softioc.pva_server_port }}
      {{- $commaSeparatedString = printf "%s.%s.svc:%d %s" ($softioc.name | lower) $domain $portAsString $commaSeparatedString }}
    {{- else }}
      {{- $commaSeparatedString = printf "%s.%s.svc %s" ($softioc.name | lower) $domain $commaSeparatedString }}
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

{{- define "pvagateway-service" -}}
{{- if hasKey .Values.epicsConfiguration.services "pvagateway" }}
{{- printf "pvagateway.%s.svc" .Values.namespace }}
{{- end }}
{{- end }}


{{- define "archiver-service" -}}
{{- if hasKey .Values.epicsConfiguration.services "archiver" }}
{{- printf "archiver.%s.svc" .Values.namespace }}
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
{{- $list := .iocs }}
{{- $domain := printf "%s" .domain}}

{{- $commaSeparatedString := "" }}

{{- range $index, $element := $list }}
  {{- if $element.disable }}
  {{- else }}
  {{- if $element.host }}
    {{- if $element.networks }}
      {{- range $element.networks}}
        {{- if .ip }}
            {{- $commaSeparatedString = printf "%s %s" .ip $commaSeparatedString }}
        {{- end}}
      {{- end}}
      {{- end}}
    {{- if $element.ca_server_port }}
      {{- $portAsString := int $element.ca_server_port }}

      {{- $commaSeparatedString = printf "%s:%d %s" $element.host $portAsString $commaSeparatedString }}
    {{- else }}
      {{- $commaSeparatedString = printf "%s %s" $element.host $commaSeparatedString }}
    {{- end}}
  {{- else }}
    {{- if $element.ca_server_port }}
      {{- $portAsString := int $element.ca_server_port }}

      {{- $commaSeparatedString = printf "%s.%s.svc:%d %s" ($element.name | lower) $domain $portAsString $commaSeparatedString }}
    {{- else }}
      {{- $commaSeparatedString = printf "%s.%s.svc %s" ($element.name | lower) $domain $commaSeparatedString }}
    {{- end }}
  {{- end }}
  {{- end}}

  {{- if ne $index (sub (len $list) 1) }}
    {{- $commaSeparatedString = printf "%s " $commaSeparatedString }}
  {{- end }} 
{{- end }}

{{- trim $commaSeparatedString }}
{{- end }}