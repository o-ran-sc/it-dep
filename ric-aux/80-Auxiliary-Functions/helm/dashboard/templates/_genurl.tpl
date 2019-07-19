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
{{/* vim: set filetype=mustache: */}}
{{/*
Generate the URLS of the endpoints.
*/}}


{{- define "dashboard.prefix.a1mediator" -}}
  {{- $ingress := ( include "common.ingressurl.ricplt" . ) -}}
  {{- if .Values.dashboard.properties.a1med.url.prefix -}}
    {{- printf "%s" .Values.dashboard.properties.a1med.url.prefix -}}
  {{- else -}}
    {{- printf "http://%s/a1mediator" $ingress -}}
  {{- end -}}
{{- end -}}

{{- define "dashboard.prefix.anrxapp" -}}
  {{- $ingress := ( include "common.ingressurl.ricxapp" . ) -}}
  {{- if .Values.dashboard.properties.anrxapp.url.prefix -}}
    {{- printf "%s" .Values.dashboard.properties.anrxapp.url.prefix -}}
  {{- else -}}
    {{- printf "http://%s/anr" $ingress -}}
  {{- end -}}
{{- end -}}

{{- define "dashboard.prefix.e2mgr" -}}
  {{- $ingress := ( include "common.ingressurl.ricplt" . ) -}}
  {{- if .Values.dashboard.properties.e2mgr.url.prefix -}}
    {{- printf "%s" .Values.dashboard.properties.e2mgr.url.prefix -}}
  {{- else -}}
    {{- printf "http://%s/e2mgr" $ingress -}}
  {{- end -}}
{{- end -}}

{{- define "dashboard.prefix.appmgr" -}}
  {{- $ingress := ( include "common.ingressurl.ricplt" . ) -}}
  {{- if .Values.dashboard.properties.appmgr.url.prefix -}}
    {{- printf "%s" .Values.dashboard.properties.appmgr.url.prefix -}}
  {{- else -}}
    {{- printf "http://%s/appmgr" $ingress -}}
  {{- end -}}
{{- end -}}
