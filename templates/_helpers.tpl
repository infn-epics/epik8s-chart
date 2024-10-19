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
  {{- $ipRange := (1 << (32 - $cidrRange)) | int -}}  # Number of IPs in the given CIDR range

  # Calculate the IP suffix based on the conversion and the available IP range
  {{- $ipSuffix := add $startIp (mod $conversion $ipRange) -}}

  # Add the calculated suffix to the base IP
  {{- $thirdOctet := add $thirdOctet (div $ipSuffix 256) -}}
  {{- $fourthOctet := mod $ipSuffix 256 -}}

  # Print the resulting IP
  {{- printf "%d.%d.%d.%d" $firstOctet $secondOctet $thirdOctet $fourthOctet -}}
{{- end -}}
