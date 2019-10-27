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
  Resolve the name of a chart's serviceaccount
*/}}


{{- define "common.serviceaccountname.appmgr" -}}
  {{- $name := ( include "common.fullname.appmgr" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceaccountname.dbaas" -}}
  {{- $name := ( include "common.fullname.dbaas" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceaccountname.e2mgr" -}}
  {{- $name := ( include "common.fullname.e2mgr" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "common.serviceaccountname.rsm" -}}
  {{- $name := ( include "common.fullname.rsm" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceaccountname.rtmgr" -}}
  {{- $name := ( include "common.fullname.rtmgr" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceaccountname.a1mediator" -}}
  {{- $name := ( include "common.fullname.a1mediator" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceaccountname.nexus" -}}
  {{- $name := ( include "common.fullname.nexus" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceaccountname.chartmuseum" -}}
  {{- $name := ( include "common.fullname.chartmuseum" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceaccountname.dashboard" -}}
  {{- $name := ( include "common.fullname.dashboard" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceaccountname.messagerouter" -}}
  {{- $name := ( include "common.fullname.messagerouter" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceaccountname.ves" -}}
  {{- $name := ( include "common.fullname.ves" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
