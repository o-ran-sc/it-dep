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
  Resolve the name of a chart's configmap.

*/}}


{{- define "common.configmapname.appmgr" -}}
  {{- $name := ( include "common.fullname.appmgr" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.dbaas" -}}
  {{- $name := ( include "common.fullname.dbaas" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}:

{{- define "common.configmapname.e2mgr" -}}
  {{- $name := ( include "common.fullname.e2mgr" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.e2term" -}}
  {{- $name := ( include "common.fullname.e2term" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.rtmgr" -}}
  {{- $name := ( include "common.fullname.rtmgr" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.submgr" -}}
  {{- $name := ( include "common.fullname.submgr" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.a1mediator" -}}
  {{- $name := ( include "common.fullname.a1mediator" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "common.configmapname.nexus" -}}
  {{- $name := ( include "common.fullname.nexus" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.dashboard" -}}
  {{- $name := ( include "common.fullname.dashboard" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.messagerouter" -}}
  {{- $name := ( include "common.fullname.messagerouter" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.ves" -}}
  {{- $name := ( include "common.fullname.ves" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
