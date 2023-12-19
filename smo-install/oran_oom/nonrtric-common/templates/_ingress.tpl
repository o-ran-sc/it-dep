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
{{- define "common.ingressClassName" -}}
  {{- if and .Values.global .Values.global.ingress -}}
    {{- default "kong" .Values.global.ingress.ingressClass -}}
  {{- else -}}
    {{- print "kong" -}}
  {{- end -}}
{{- end -}}

{{- define "common.ingressEnabled" -}}
  {{- if and .Values.global .Values.global.ingress -}}
    {{- if .Values.global.ingress.enabled -}}
      {{- if or .Values.global.ingress.enabled_all .Values.ingress.enabled -}}
  true
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- .Values.ingress.enabled -}}
  {{- end -}}
{{- end -}}
