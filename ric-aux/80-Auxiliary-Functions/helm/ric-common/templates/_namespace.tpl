################################################################################
#   Copyright (c) 2019 AT&T Intellectual Property.                             #
#   Copyright (c) 2019 Nokia.                                                  #
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

{{/*
  Resolve the namespace to apply to a chart. The default namespace suffix
  is the name of the chart. This can be overridden if necessary (eg. for subcharts)
  using the following value:

  - .Values.nsPrefix  : override namespace prefix
*/}}

{{- define "common.namespace.platform" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.namespace -}}
      {{- if .Values.global.namespace.platform -}}
        {{- printf "%s" .Values.global.namespace.platform -}}
      {{- else -}}
        {{- printf "ricplt" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "ricplt" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricplt" -}}
  {{- end -}}
{{- end -}}

{{- define "common.namespace.aux" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.namespace -}}
      {{- if .Values.global.namespace.aux -}}
        {{- printf "%s" .Values.global.namespace.aux -}}
      {{- else -}}
        {{- printf "ricaux" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "ricaux" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricaux" -}}
  {{- end -}}
{{- end -}}

{{- define "common.namespace.xapp" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.namespace -}}
      {{- if .Values.global.namespace.xapp -}}
        {{- printf "%s" .Values.global.namespace.xapp -}}
      {{- else -}}
        {{- printf "ricxapp" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "ricxapp" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricxapp" -}}
  {{- end -}}
{{- end -}}

{{- define "common.namespace.infra" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.namespace -}}
      {{- if .Values.global.namespace.infra -}}
        {{- printf "%s" .Values.global.namespace.infra -}}
      {{- else -}}
        {{- printf "ricinfra" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "ricinfra" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricinfra" -}}
  {{- end -}}
{{- end -}}

{{- define "common.namespace" -}}
  {{- default .Release.Namespace .Values.nsPrefix -}}
{{- end -}}
