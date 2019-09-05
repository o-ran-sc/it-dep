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
  {{- $namespace := ( include "common.namespace.platform" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
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
  {{- $namespace := ( include "common.namespace.platform" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
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
  {{- $namespace := ( include "common.namespace.platform" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
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
  {{- $namespace := ( include "common.namespace.platform" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
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
  {{- $namespace := ( include "common.namespace.platform" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}






{{- define "common.name.submgr" -}}
  {{- if .Values.submgr -}}
    {{- if .Values.submgr.nameOverride -}}
      {{- printf "%s" .Values.submgr.nameOverride -}}
    {{- else -}}
      {{- printf "submgr" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "submgr" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.submgr" -}}
  {{- $name := ( include "common.name.submgr" . ) -}}
  {{- $namespace := ( include "common.namespace.platform" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}






{{- define "common.name.a1mediator" -}}
  {{- if .Values.a1mediator -}}
    {{- if .Values.a1mediator.nameOverride -}}
      {{- printf "%s" .Values.a1mediator.nameOverride -}}
    {{- else -}}
      {{- printf "a1mediator" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "a1mediator" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.a1mediator" -}}
  {{- $name := ( include "common.name.a1mediator" . ) -}}
  {{- $namespace := ( include "common.namespace.platform" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "common.name.vespamgr" -}}
  {{- if .Values.vespamgr -}}
    {{- if .Values.vespamgr.nameOverride -}}
      {{- printf "%s" .Values.vespamgr.nameOverride -}}
    {{- else -}}
      {{- printf "vespamgr" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "vespamgr" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.vespamgr" -}}
  {{- $name := ( include "common.name.vespamgr" . ) -}}
  {{- $namespace := ( include "common.namespace.platform" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}




{{- define "common.name.nexus" -}}
  {{- if .Values.nexus -}}
    {{- if .Values.nexus.nameOverride -}}
      {{- printf "%s" .Values.nexus.nameOverride -}}
    {{- else -}}
      {{- printf "nexus" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "nexus" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.nexus" -}}
  {{- $name := ( include "common.name.nexus" . ) -}}
  {{- $namespace := ( include "common.namespace.infra" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.name.chartmuseum" -}}
  {{- if .Values.chartmuseum -}}
    {{- if .Values.chartmuseum.nameOverride -}}
      {{- printf "%s" .Values.chartmuseum.nameOverride -}}
    {{- else -}}
      {{- printf "chartmuseum" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "chartmuseum" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.chartmuseum" -}}
  {{- $name := ( include "common.name.chartmuseum" . ) -}}
  {{- $namespace := ( include "common.namespace.infra" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.name.dashboard" -}}
  {{- if .Values.dashboard -}}
    {{- if .Values.dashboard.nameOverride -}}
      {{- printf "%s" .Values.dashboard.nameOverride -}}
    {{- else -}}
      {{- printf "dashboard" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "dashboard" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.dashboard" -}}
  {{- $name := ( include "common.name.dashboard" . ) -}}
  {{- $namespace := ( include "common.namespace.aux" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.name.messagerouter" -}}
  {{- if .Values.messagerouter -}}
    {{- if .Values.messagerouter.nameOverride -}}
      {{- printf "%s" .Values.messagerouter.nameOverride -}}
    {{- else -}}
      {{- printf "messagerouter" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "messagerouter" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.messagerouter" -}}
  {{- $name := ( include "common.name.messagerouter" . ) -}}
  {{- $namespace := ( include "common.namespace.aux" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "common.name.ves" -}}
  {{- if .Values.ves -}}
    {{- if .Values.ves.nameOverride -}}
      {{- printf "%s" .Values.ves.nameOverride -}}
    {{- else -}}
      {{- printf "ves" -}}
    {{- end -}}
  {{- else -}}
    {{- printf "ves" -}}
  {{- end -}}
{{- end -}}


{{- define "common.fullname.ves" -}}
  {{- $name := ( include "common.name.ves" . ) -}}
  {{- $namespace := ( include "common.namespace.aux" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
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
  {{- printf "%s-%s" .Release.Namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
