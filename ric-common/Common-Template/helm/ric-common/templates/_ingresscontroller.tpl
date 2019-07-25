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
  Resolve the ingress controller addresses.
*/}}

####################### Service URL #####################################
{{- define "common.ingressurl.ricplt" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.ingressurl -}}
      {{- if .Values.global.ingressurl.platform -}}
        {{- printf "%s" .Values.global.ingressurl.platform -}}
      {{- else -}}
        {{- printf "ricplt-entry" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "ricplt-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricplt-entry" -}}
  {{- end -}}
{{- end -}}

{{- define "common.ingressurl.ricxapp" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.ingressurl -}}
      {{- if .Values.global.ingressurl.xapp -}}
        {{- printf "%s" .Values.global.ingressurl.xapp -}}
      {{- else -}}
        {{- printf "ricxapp-entry" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "ricxapp-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricxapp-entry" -}}
  {{- end -}}
{{- end -}}

{{- define "common.ingressurl.ricaux" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.ingressurl -}}
      {{- if .Values.global.ingressurl.aux -}}
        {{- printf "%s" .Values.global.ingressurl.aux -}}
      {{- else -}}
        {{- printf "ricaux-entry" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "ricaux-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricaux-entry" -}}
  {{- end -}}
{{- end -}}

{{- define "common.ingressurl.ricinfra" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.ingressurl -}}
      {{- if .Values.global.ingressurl.infra -}}
        {{- printf "%s" .Values.global.ingressurl.infra -}}
      {{- else -}}
        {{- printf "ricinfra-entry" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "ricinfra-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricinfra-entry" -}}
  {{- end -}}
{{- end -}}

{{- define "common.ingressurl.localdocker" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.ingressurl -}}
      {{- if .Values.global.ingressurl.localdocker -}}
        {{- printf "%s" .Values.global.ingressurl.localdocker -}}
      {{- else -}}
        {{- printf "docker-entry" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "docker-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "docker-entry" -}}
  {{- end -}}
{{- end -}}

{{- define "common.ingressurl.localhelm" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.ingressurl -}}
      {{- if .Values.global.ingressurl.localhelm -}}
        {{- printf "%s" .Values.global.ingressurl.localhelm -}}
      {{- else -}}
        {{- printf "helm-entry" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "helm-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "helm-entry" -}}
  {{- end -}}
{{- end -}}


{{- define "common.ingressurl.localnexus" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.ingressurl -}}
      {{- if .Values.global.ingressurl.localnexus -}}
        {{- printf "%s" .Values.global.ingressurl.localnexus -}}
      {{- else -}}
        {{- printf "nexus-entry" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "nexus-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "nexus-entry" -}}
  {{- end -}}
{{- end -}}






####################### Ingress Controller Ports ###########################################
## Currently the below values are hard-coded due to the fact that kong ingress controller  #
## helm charts are not using this common template. We need to make sure that these values  #
## agree with the values in the kong helm charts values.yaml files.                        #
############################################################################################  
{{- define "common.ingresshttpport.ricplt" -}}
  {{- printf "30180" -}}
{{- end -}}

{{- define "common.ingresshttpsport.ricplt" -}}
  {{- printf "30443" -}}
{{- end -}}


{{- define "common.ingresshttpport.ricxapp" -}}
  {{- printf "31080" -}}
{{- end -}}


{{- define "common.ingresshttpsport.ricxapp" -}}
  {{- printf "31443" -}}
{{- end -}}


{{- define "common.ingresshttpport.ricaux" -}}
  {{- printf "32080" -}}
{{- end -}}

{{- define "common.ingresshttpsport.ricaux" -}}
  {{- printf "32443" -}}
{{- end -}}


{{- define "common.ingresshttpport.ricinfra" -}}
  {{- printf "32180" -}}
{{- end -}}



{{- define "common.ingresshttpsport.ricinfra" -}}
  {{- printf "32543" -}}
{{- end -}}

