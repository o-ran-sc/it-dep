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


###################### RMR Service ##################################
{{- define "common.servicename.appmgr.rmr" -}}
  {{- $name := ( include "common.fullname.appmgr" . ) -}}
  {{- printf "service-%s-rmr" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "common.servicename.e2mgr.rmr" -}}
  {{- $name := ( include "common.fullname.e2mgr" . ) -}}
  {{- printf "service-%s-rmr" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.rsm.rmr" -}}
  {{- $name := ( include "common.fullname.rsm" . ) -}}
  {{- printf "service-%s-rmr" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.rtmgr.rmr" -}}
  {{- $name := ( include "common.fullname.rtmgr" . ) -}}
  {{- printf "service-%s-rmr" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.submgr.rmr" -}}
  {{- $name := ( include "common.fullname.submgr" . ) -}}
  {{- printf "service-%s-rmr" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.a1mediator.rmr" -}}
  {{- $name := ( include "common.fullname.a1mediator" . ) -}}
  {{- printf "service-%s-rmr" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


###################### Http Service ##################################

{{- define "common.servicename.appmgr.http" -}}
  {{- $name := ( include "common.fullname.appmgr" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.e2mgr.http" -}}
  {{- $name := ( include "common.fullname.e2mgr" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.rsm.http" -}}
  {{- $name := ( include "common.fullname.rsm" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.rtmgr.http" -}}
  {{- $name := ( include "common.fullname.rtmgr" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.submgr.http" -}}
  {{- $name := ( include "common.fullname.submgr" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.a1mediator.http" -}}
  {{- $name := ( include "common.fullname.a1mediator" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.vespamgr.http" -}}
  {{- $name := ( include "common.fullname.vespamgr" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.nexus.http" -}}
  {{- $name := ( include "common.fullname.nexus" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.chartmuseum.http" -}}
  {{- $name := ( include "common.fullname.chartmuseum" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.dashboard.http" -}}
  {{- $name := ( include "common.fullname.dashboard" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.ves.http" -}}
  {{- $name := ( include "common.fullname.ves" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.jaegeradapter.query" -}}
  {{- $name := ( include "common.fullname.jaegeradapter" . ) -}}
  {{- printf "service-%s-query" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "common.servicename.jaegeradapter.collector" -}}
  {{- $name := ( include "common.fullname.jaegeradapter" . ) -}}
  {{- printf "service-%s-collector" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- define "common.servicename.jaegeradapter.agent" -}}
  {{- $name := ( include "common.fullname.jaegeradapter" . ) -}}
  {{- printf "service-%s-agent" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

###################### TCP Service ##################################

{{- define "common.servicename.dbaas.tcp" -}}
  {{- $name := ( include "common.fullname.dbaas" . ) -}}
  {{- printf "service-%s-tcp" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.messagerouter.tcp" -}}
  {{- $name := ( include "common.fullname.messagerouter" . ) -}}
  {{- printf "service-%s-tcp" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.ves.tcp" -}}
  {{- $name := ( include "common.fullname.ves" . ) -}}
  {{- printf "service-%s-tcp" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}



#################### Default ###############


{{/*
  Resolve the name of a chart's service.

  The default will be the chart name (or .Values.nameOverride if set).
  And the use of .Values.service.name overrides all.

  - .Values.service.name  : override default service (ie. chart) name
*/}}
{{/*
  Expand the service name for a chart.
*/}}
{{- define "common.servicename" -}}
  {{- $name := default .Chart.Name .Values.nameOverride -}}
  {{- default $name .Values.service.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
