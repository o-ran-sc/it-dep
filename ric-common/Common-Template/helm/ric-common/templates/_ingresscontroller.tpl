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
{{- define "common.ingressurl.ric" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.ingressurl -}}
      {{- if .Values.global.ingressurl.ric -}}
        {{- printf "%s" .Values.global.ingressurl.ric -}}
      {{- else -}}
        {{- printf "ric-entry" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "ric-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ric-entry" -}}
  {{- end -}}
{{- end -}}


{{- define "common.ingressurl.aux" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.ingressurl -}}
      {{- if .Values.global.ingressurl.aux -}}
        {{- printf "%s" .Values.global.ingressurl.aux -}}
      {{- else -}}
        {{- printf "aux-entry" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "aux-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "aux-entry" -}}
  {{- end -}}
{{- end -}}

{{- define "common.ingressurl.dashboard" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.ingressurl -}}
      {{- if .Values.global.ingressurl.dashboard -}}
        {{- printf "%s" .Values.global.ingressurl.dashboard -}}
      {{- else -}}
        {{- printf "dashboard-entry" -}}
      {{- end -}}
    {{- else -}}
      {{- printf "dashboard-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "dashboard-entry" -}}
  {{- end -}}
{{- end -}}


####################### Ingress Controller Ports ###########################################
## Currently the below values are hard-coded due to the fact that kong ingress controller  #
## helm charts are not using this common template. We need to make sure that these values  #
## agree with the values in the kong helm charts values.yaml files.                        #
############################################################################################  
{{- define "common.ingresshttpport" -}}
  {{- printf "32080" -}}
{{- end -}}

{{- define "common.ingresshttpsport" -}}
  {{- printf "32443" -}}
{{- end -}}

