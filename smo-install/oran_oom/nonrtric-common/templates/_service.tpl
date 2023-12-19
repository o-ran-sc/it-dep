{{/*
# Copyright © 2017 Amdocs, Bell Canada
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
*/}}
{{/*
  Resolve the name of a chart's service.

  The default will be the chart name (or .Values.nameOverride if set).
  And the use of .Values.service.name overrides all.

  - .Values.service.name: override default service (ie. chart) name
*/}}
{{/*
  Expand the service name for a chart.
*/}}
{{- define "common.servicename" -}}
  {{- $name := default .Chart.Name .Values.nameOverride -}}
  {{- default $name .Values.service.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Define the metadata of Service
     The function takes from one to four arguments (inside a dictionary):
     - .dot : environment (.)
     - .suffix : a string which will be added at the end of the name (with a '-').
     - .annotations: the annotations to add
     - .labels : labels to add
     Usage example:
      {{ include "common.serviceMetadata" ( dict "suffix" "myService" "dot" .) }}
      {{ include "common.serviceMetadata" ( dict "annotations" .Values.service.annotation "dot" .) }}
*/}}

{{- define "common.serviceMetadata" -}}
  {{- $dot := default . .dot -}}
  {{- $suffix := default "" .suffix -}}
  {{- $annotations := default "" .annotations -}}
  {{- $labels := default (dict) .labels -}}
{{- if $annotations -}}
annotations:
{{  include "common.tplValue" (dict "value" $annotations "context" $dot) | indent 2 }}
{{- end -}}
name: {{ include "common.servicename" $dot }}{{ if $suffix }}{{ print "-" $suffix }}{{ end }}
namespace: {{ include "common.namespace" $dot }}
labels: {{- include "common.labels" (dict "labels" $labels "dot" $dot) | nindent 2 -}}
{{- end -}}

{{/* Define the ports of Service
     The function takes three arguments (inside a dictionary):
     - .dot : environment (.)
     - .ports : an array of ports
     - .serviceType: the type of the service
*/}}
{{- define "common.servicePorts" -}}
{{- $serviceType := .serviceType -}}
{{- $dot := .dot -}}
{{-   range $index, $port := .ports -}}
{{-   if $port.targetPort -}}
- name: {{ $port.name }}
  port: {{ default $port.targetPort $port.internalPort }}
  targetPort: {{ $port.targetPort }}
{{-       if (and (eq $serviceType "NodePort") $port.nodePort) }}
  nodePort: {{ $port.nodePort }}
{{-       end }}
{{-       if $port.l4_protocol }}
  protocol: {{ $port.l4_protocol }}
{{-       else }}
  protocol: TCP
{{-       end }}
{{-       if $port.app_protocol }}
  appProtocol: {{ $port.app_protocol }}
{{-       end }}
{{-     end }}
{{-     if $port.internalPort_tls }}
- name: {{ $port.name_tls }}
  port: {{ default $port.targetPort_tls $port.internalPort_tls }}
  targetPort: {{ $port.targetPort_tls }}
{{-       if (and (eq $serviceType "NodePort") $port.nodePort_tls) }}
  nodePort: {{ $port.nodePort_tls }}
{{-       end }}
{{-       if $port.l4_protocol }}
  protocol: {{ $port.l4_protocol }}
{{-       else }}
  protocol: TCP
{{-       end }}
{{-       if $port.app_protocol }}
  appProtocol: {{ $port.app_protocol }}
{{-       end }}
{{-     end }}
{{   end }}
{{- end -}}

{{/* Create generic service template
     The function takes several arguments (inside a dictionary):
     - .dot : environment (.)
     - .ports : an array of ports
     - .serviceType: the type of the service
     - .suffix : a string which will be added at the end of the name (with a '-')
     - .annotations: the annotations to add
     - .publishNotReadyAddresses: if we publish not ready address
     - .headless: if the service is headless
     - .add_plain_port: add tls port AND plain port
     - .labels : labels to add (dict)
     - .matchLabels: selectors/machLabels to add (dict)
*/}}
{{- define "common.service" -}}
{{-   $dot := default . .dot -}}
{{-   $suffix := default "" $dot.Values.service.suffix -}}
{{-   $annotations := default "" $dot.Values.service.annotations -}}
{{-   $publishNotReadyAddresses := default false $dot.Values.service.publishNotReadyAddresses -}}
{{-   $serviceType := $dot.Values.service.type -}}
{{-   $ports := $dot.Values.service.ports -}}
{{-   $labels := default (dict) .labels -}}
{{-   $matchLabels := default (dict) .matchLabels -}}
{{-   $ipFamilyPolicy := default "PreferDualStack" $dot.Values.service.ipFamilyPolicy -}}
apiVersion: v1
kind: Service
metadata: {{- include "common.serviceMetadata" (dict "suffix" $suffix "annotations" $annotations "labels" $labels "dot" $dot) | nindent 2 }}
spec:
  ports: {{- include "common.servicePorts" (dict "serviceType" $serviceType "ports" $ports "dot" $dot) | nindent 4 }}
  ipFamilyPolicy: {{ $ipFamilyPolicy }}
  {{- if $publishNotReadyAddresses }}
  publishNotReadyAddresses: true
  {{- end }}
  type: {{ $serviceType }}
  selector: {{- include "common.matchLabels" (dict "matchLabels" $matchLabels "dot" $dot) | nindent 4 }}
{{- end -}}