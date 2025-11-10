{{- define "pvaiocnames" -}}
{{- $list := .iocs }}
{{- $domain := printf "%s" .domain}}

{{- $commaSeparatedString := "" }}

{{- range $index, $element := $list }}

  {{- if and (not $element.disable) ($element.pva) }}
    {{- if $element.host }}
      {{- $ips := 0 }}
      {{- if $element.networks }}
      {{- range $element.networks}}
        {{- if .ip }}
            {{- $commaSeparatedString = printf "%s %s" .ip $commaSeparatedString}}
            {{- $ips := 1 }}

        {{- end}}
      {{- end}}
      {{- else }}
      {{- if $element.pva_server_port }}
        {{- $portAsString := int $element.pva_server_port }}
        {{- $commaSeparatedString = printf "%s:%d %s" $element.host $portAsString $commaSeparatedString }}
      {{- else }}
        {{- $commaSeparatedString = printf "%s %s" $element.host $commaSeparatedString }}
      {{- end }}
      {{- end }}
    {{- else }}
      {{- if $element.pva_server_port }}
        {{- $portAsString := int $element.pva_server_port }}
          {{- $commaSeparatedString = printf "%s.%s.svc:%d %s" $element.name $domain $portAsString $commaSeparatedString }}
      {{- else }}
        {{- $commaSeparatedString = printf "%s.%s.svc %s" $element.name $domain $commaSeparatedString }}
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

  {{- /* Generate hash and convert to integer */}}
  {{- $hash := adler32sum $name -}}
  {{- $conversion := atoi $hash -}}

  {{- /* Parse CIDR */}}
  {{- $baseIpParts := split "/" $baseIpWithCIDR -}}
  {{- $baseIp := index $baseIpParts "_0" -}}
  {{- $cidrRange := index $baseIpParts "_1" | int -}}

  {{- /* Calculate total available IPs in subnet (excluding network and broadcast) */}}
  {{- $totalIps := sub (mul 1 (sub 32 $cidrRange)) 2 -}}
  {{- if le $totalIps 0 -}}
    {{- $totalIps = 1 -}}
  {{- end -}}

  {{- /* Generate IP offset within subnet range */}}
  {{- $ipOffset := mod (add $conversion $startIp) $totalIps -}}

  {{- /* Parse base IP octets */}}
  {{- $octets := split "." $baseIp -}}
  {{- $firstOctet := index $octets "_0" | int -}}
  {{- $secondOctet := index $octets "_1" | int -}}
  {{- $thirdOctet := index $octets "_2" | int -}}
  {{- $fourthOctet := index $octets "_3" | int -}}

  {{- /* Calculate final IP: base_ip + offset */}}
  {{- $finalIp := add $fourthOctet $ipOffset -}}
  {{- $carry := 0 -}}

  {{- /* Handle octet overflow with carry */}}
  {{- if ge $finalIp 256 -}}
    {{- $carry = div $finalIp 256 -}}
    {{- $finalIp = mod $finalIp 256 -}}
  {{- end -}}
  {{- $thirdOctet = add $thirdOctet $carry -}}
  {{- $carry = 0 -}}

  {{- if ge $thirdOctet 256 -}}
    {{- $carry = div $thirdOctet 256 -}}
    {{- $thirdOctet = mod $thirdOctet 256 -}}
  {{- end -}}
  {{- $secondOctet = add $secondOctet $carry -}}
  {{- $carry = 0 -}}

  {{- if ge $secondOctet 256 -}}
    {{- $carry = div $secondOctet 256 -}}
    {{- $secondOctet = mod $secondOctet 256 -}}
  {{- end -}}
  {{- $firstOctet = add $firstOctet $carry -}}

  {{- /* Ensure IP stays within valid range (0-255) */}}
  {{- if gt $firstOctet 255 -}}
    {{- $firstOctet = 255 -}}
  {{- end -}}
  {{- if gt $secondOctet 255 -}}
    {{- $secondOctet = 255 -}}
  {{- end -}}
  {{- if gt $thirdOctet 255 -}}
    {{- $thirdOctet = 255 -}}
  {{- end -}}
  {{- if gt $finalIp 255 -}}
    {{- $finalIp = 255 -}}
  {{- end -}}

  {{- printf "%d.%d.%d.%d" $firstOctet $secondOctet $thirdOctet $finalIp -}}
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

      {{- $commaSeparatedString = printf "%s.%s.svc:%d %s" $element.name $domain $portAsString $commaSeparatedString }}
    {{- else }}
      {{- $commaSeparatedString = printf "%s.%s.svc %s" $element.name $domain $commaSeparatedString }}
    {{- end }}
  {{- end }}
  {{- end}}

  {{- if ne $index (sub (len $list) 1) }}
    {{- $commaSeparatedString = printf "%s " $commaSeparatedString }}
  {{- end }} 
{{- end }}

{{- trim $commaSeparatedString }}
{{- end }}