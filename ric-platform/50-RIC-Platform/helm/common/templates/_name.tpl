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
  This is the root file that define the name of each component. Value here will be used to define other K8S resource name.
*/}}



{{- define "common.name.appmgr" -}}
  {{- if .Values.appmgr -}}
    {{- if .Values.appmgr.nameOverride -}}
      {{- printf "%s" .Values.appmgr.nameOverride -}}
    {{- else -}}
      {{- printf "appmgr" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "appmgr" -}}
  {{- end -}}
{{- end -}}

{{- define "common.fullname.appmgr" -}}
  {{- $name := ( include "common.name.appmgr" . ) -}}
  {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "common.name.dbaas" -}}
  {{- if .Values.dbaas -}}
    {{- if .Values.dbaas.nameOverride -}}
      {{- printf "%s" .Values.dbaas.nameOverride -}}
    {{- else -}}
      {{- printf "dbaas" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "dbaas" -}}
  {{- end -}}
{{- end -}}

{{- define "common.fullname.dbaas" -}}
  {{- $name := ( include "common.name.dbaas" . ) -}}
  {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}











{{- define "common.name.e2mgr" -}}
  {{- if .Values.e2mgr -}}
    {{- if .Values.e2mgr.nameOverride -}}
      {{- printf "%s" .Values.e2mgr.nameOverride -}}
    {{- else -}}
      {{- printf "e2mgr" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "e2mgr" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.e2mgr" -}}
  {{- $name := ( include "common.name.e2mgr" . ) -}}
  {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.name.e2term" -}}
  {{- if .Values.e2term -}}
    {{- if .Values.e2term.nameOverride -}}
      {{- printf "%s" .Values.e2term.nameOverride -}}
    {{- else -}}
      {{- printf "e2term" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "e2term" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.e2term" -}}
  {{- $name := ( include "common.name.e2term" . ) -}}
  {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}









{{- define "common.name.rtmgr" -}}
  {{- if .Values.rtmgr -}}
    {{- if .Values.rtmgr.nameOverride -}}
      {{- printf "%s" .Values.rtmgr.nameOverride -}}
    {{- else -}}
      {{- printf "rtmgr" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "rtmgr" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.rtmgr" -}}
  {{- $name := ( include "common.name.rtmgr" . ) -}}
  {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}














{{- define "common.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Create a default fully qualified application name.
  Truncated at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "common.fullname" -}}
  {{- $name := default .Chart.Name .Values.nameOverride -}}
  {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
