{{/*
################################################################################
#   Copyright (c) 2024 NYCU WINLab.                                            #
#                                                                              #
#   Licensed under the Apache License, Version 2.0 (the "License");            #
#   you may not use this file except in compliance with the License.           #
#   You may obtain a copy of the License at                                    #
#                                                                              #
#       http://www.apache.org/licenses/LICENSE-2.0                             #
#                                                                              #
#   Unless required by applicable law or agreed to in writing, software        #
#   distributed under the License is distributed on an "AS IS" BASIS,          #
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
#   See the License for the specific language governing permissions and        #
#   limitations under the License.                                             #
################################################################################
*/}}

{{- define "common.containerPorts" -}}
{{-   $ports := default (list) .Values.service.ports }}
{{-   range $index, $port := $ports }}
{{-   if $port.targetPort -}}
- containerPort: {{ $port.targetPort }}
  name: {{ $port.name }}
{{-       if $port.l4_protocol }}
  protocol: {{ $port.l4_protocol }}
{{-       else }}
  protocol: TCP
{{-       end }}
{{-     end }}
{{- if $port.targetPort_tls }}
- containerPort: {{ $port.targetPort_tls }}
  name: {{ $port.name_tls }}
{{-       if $port.l4_protocol }}
  protocol: {{ $port.l4_protocol }}
{{-       else }}
  protocol: TCP
{{-       end }}
{{-     end }}
{{-   end }}
{{- end -}}

{{- define "common.probePort" -}}
{{ default (first .Values.service.ports).targetPort .Values.service.probePort }}
{{- end -}}

{{- define "common.tcpsocketReadinessProbe" -}}
{{- $dot := default . .dot -}}
{{- $port := default (include "common.probePort" $dot) .port -}}
readinessProbe:
  tcpSocket:
    port: {{ $port }}
  initialDelaySeconds: {{ $dot.Values.readiness.initialDelaySeconds }}
  periodSeconds: {{ $dot.Values.readiness.periodSeconds }}
{{- end -}}

{{- define "common.tcpsocketLivenessProbe" -}}
{{- $dot := default . .dot -}}
{{- $port := default (include "common.probePort" $dot) .port -}}
livenessProbe:
  tcpSocket:
    port: {{ $port }}
  initialDelaySeconds: {{ $dot.Values.liveness.initialDelaySeconds }}
  periodSeconds: {{ $dot.Values.liveness.periodSeconds }}
{{- end -}}

{{- define "common.tcpsocketProbes" -}}
{{- include "common.tcpsocketReadinessProbe" . }}
{{ include "common.tcpsocketLivenessProbe" . }}
{{- end -}}

{{- define "common.httpLiveProbe" -}}
{{- $dot := default . .dot }}
{{- $path := default "/status" .path -}}
livenessProbe:
  httpGet:
    path: {{ $path }}
    port: {{ include "common.probePort" . }}
  initialDelaySeconds: {{ $dot.Values.liveness.initialDelaySeconds }}
  periodSeconds: {{ $dot.Values.liveness.periodSeconds }}
{{- end -}}

{{- define "common.applicationConfigMountName" -}}
{{ include "common.name" . }}-application-config
{{- end -}}

{{- define "common.applicationConfigVolume" -}}
- name: {{ include "common.name" . }}-application-config
  configMap:
    name: {{ include "common.name" . }}-application-configmap
{{- end -}}

