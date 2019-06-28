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
{{- define "common.ingressurl.ricplt" -}}
  {{- if .Values.kongplatform -}}
    {{- if .Values.kongplatform.ingressurlOverride -}}
      {{- printf "%s" .Values.kongplatform.ingressurlOverride -}}
    {{- else -}}
      {{- printf "ricplt-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricplt-entry" -}}
  {{- end -}}
{{- end -}}



{{- define "common.ingresshttpport.ricplt" -}}
  {{- if .Values.kongplatform -}}
    {{- if .Values.kongplatform.ingresshttpportOverride -}}
      {{- printf "%.0f" .Values.kongplatform.ingresshttpportOverride -}}
    {{- else -}}
      {{- printf "30080" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "30080" -}}
  {{- end -}}
{{- end -}}



{{- define "common.ingresshttpsport.ricplt" -}}
  {{- if .Values.kongplatform -}}
    {{- if .Values.kongplatform.ingresshttpsportOverride -}}
      {{- printf "%.0f" .Values.kongplatform.ingresshttpsportOverride -}}
    {{- else -}}
      {{- printf "30443" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "30443" -}}
  {{- end -}}
{{- end -}}
















{{- define "common.ingressurl.ricxapp" -}}
  {{- if .Values.kongxapp -}}
    {{- if .Values.kongxapp.ingressurlOverride -}}
      {{- printf "%s" .Values.kongxapp.ingressurlOverride -}}
    {{- else -}}
      {{- printf "ricxapp-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricxapp-entry" -}}
  {{- end -}}
{{- end -}}



{{- define "common.ingresshttpport.ricxapp" -}}
  {{- if .Values.kongxapp -}}
    {{- if .Values.kongxapp.ingresshttpportOverride -}}
      {{- printf "%.0f" .Values.kongxapp.ingresshttpportOverride -}}
    {{- else -}}
      {{- printf "31080" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "31080" -}}
  {{- end -}}
{{- end -}}



{{- define "common.ingresshttpsport.ricxapp" -}}
  {{- if .Values.kongxapp -}}
    {{- if .Values.kongxapp.ingresshttpsportOverride -}}
      {{- printf "%.0f" .Values.kongxapp.ingresshttpsportOverride -}}
    {{- else -}}
      {{- printf "31443" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "31443" -}}
  {{- end -}}
{{- end -}}



{{- define "common.ingressurl.ricaux" -}}
  {{- if .Values.kongaux -}}
    {{- if .Values.kongaux.ingressurlOverride -}}
      {{- printf "%s" .Values.kongaux.ingressurlOverride -}}
    {{- else -}}
      {{- printf "ricaux-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricaux-entry" -}}
  {{- end -}}
{{- end -}}





{{- define "common.ingresshttpport.ricaux" -}}
  {{- if .Values.kongaux -}}
    {{- if .Values.kongaux.ingresshttpportOverride -}}
      {{- printf "%.0f" .Values.kongaux.ingresshttpportOverride -}}
    {{- else -}}
      {{- printf "32080" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "32080" -}}
  {{- end -}}
{{- end -}}



{{- define "common.ingresshttpsport.ricaux" -}}
  {{- if .Values.kongaux -}}
    {{- if .Values.kongaux.ingresshttpsportOverride -}}
      {{- printf "%.0f" .Values.kongaux.ingresshttpsportOverride -}}
    {{- else -}}
      {{- printf "32443" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "32443" -}}
  {{- end -}}
{{- end -}}
















{{- define "common.ingressurl.ricinfra" -}}
  {{- if .Values.konginfra -}}
    {{- if .Values.konginfra.ingressurlOverride -}}
      {{- printf "%s" .Values.konginfra.ingressurlOverride -}}
    {{- else -}}
      {{- printf "ricinfra-entry" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ricinfra-entry" -}}
  {{- end -}}
{{- end -}}





{{- define "common.ingresshttpport.ricinfra" -}}
  {{- if .Values.konginfra -}}
    {{- if .Values.konginfra.ingresshttpportOverride -}}
      {{- printf "%.0f" .Values.konginfra.ingresshttpportOverride -}}
    {{- else -}}
      {{- printf "33080" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "33080" -}}
  {{- end -}}
{{- end -}}



{{- define "common.ingresshttpsport.ricinfra" -}}
  {{- if .Values.konginfra -}}
    {{- if .Values.konginfra.ingresshttpsportOverride -}}
      {{- printf "%.0f" .Values.konginfra.ingresshttpsportOverride -}}
    {{- else -}}
      {{- printf "33443" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "33443" -}}
  {{- end -}}
{{- end -}}

