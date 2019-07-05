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


{{- define "dashboard.endpoint.a1mediator" -}}
  {{- $ingress := ( include "common.ingressurl.ricplt" . ) -}}
  {{- if .Values.dashboard.properties.a1med.urlOverride -}}
    {{- printf "%s" .Values.dashboard.properties.a1med.urlOverride -}}
  {{- else -}}
    {{- printf "http://%s/a1mediator%s" $ingress .Values.dashboard.properties.a1med.urlSuffix -}}
  {{- end -}}
{{- end -}}

{{- define "dashboard.endpoint.anrxapp" -}}
  {{- $ingress := ( include "common.ingressurl.ricxapp" . ) -}}
  {{- if .Values.dashboard.properties.anrxapp.urlOverride -}}
    {{- printf "%s" .Values.dashboard.properties.anrxapp.urlOverride -}}
  {{- else -}}
    {{- printf "http://%s/anr%s" $ingress .Values.dashboard.properties.anrxapp.urlSuffix -}}
  {{- end -}}
{{- end -}}

{{- define "dashboard.endpoint.e2mgr" -}}
  {{- $ingress := ( include "common.ingressurl.ricplt" . ) -}}
  {{- if .Values.dashboard.properties.e2mgr.urlOverride -}}
    {{- printf "%s" .Values.dashboard.properties.e2mgr.urlOverride -}}
  {{- else -}}
    {{- printf "http://%s/e2mgr%s" $ingress .Values.dashboard.properties.e2mgr.urlSuffix -}}
  {{- end -}}
{{- end -}}
    
{{- define "dashboard.endpoint.xappmgr" -}}
  {{- $ingress := ( include "common.ingressurl.ricplt" . ) -}}
  {{- if .Values.dashboard.properties.xappmgr.urlOverride -}}
    {{- printf "%s" .Values.dashboard.properties.xappmgr.urlOverride -}}
  {{- else -}}
    {{- printf "http://%s/appmgr%s" $ingress .Values.dashboard.properties.xappmgr.urlSuffix -}}
  {{- end -}}
{{- end -}}
