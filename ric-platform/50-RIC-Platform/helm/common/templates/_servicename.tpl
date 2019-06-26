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
  Resolve the name of a chart's service.

  The default will be the chart name (or .Values.nameOverride if set).
  And the use of .Values.service.name overrides all.

  - .Values.service.name  : override default service (ie. chart) name
*/}}
{{/*
  Expand the service name for a chart.
*/}}


{{- define "common.servicename.appmgr" -}}
  {{- $name := ( include "common.fullname.appmgr" . ) -}}
  {{- printf "service-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.dbaas" -}}
  {{- $name := ( include "common.name.dbaas" . ) -}}
  {{- printf "service-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.e2mgr" -}}
  {{- $name := ( include "common.fullname.e2mgr" . ) -}}
  {{- printf "service-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.e2term" -}}
  {{- $name := ( include "common.fullname.e2term" . ) -}}
  {{- printf "service-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.rtmgr" -}}
  {{- $name := ( include "common.fullname.rtmgr" . ) -}}
  {{- printf "service-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.a1mediator" -}}
  {{- $name := ( include "common.fullname.a1mediator" . ) -}}
  {{- printf "service-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}



