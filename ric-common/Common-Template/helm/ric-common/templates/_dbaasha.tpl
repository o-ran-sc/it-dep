################################################################################
#   Copyright (c) 2019 AT&T Intellectual Property.                             #
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

{{- define "common.name.dbaasha" -}}
  {{- printf "dbaasha" -}}
{{- end -}}

{{- define "common.fullname.dbaasha" -}}
  {{- $name := ( include "common.name.dbaasha" . ) -}}
  {{- $namespace := ( include "common.namespace.platform" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.dbaasha" -}}
  {{- $name := ( include "common.fullname.dbaasha" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.statefulsetname.dbaasha" -}}
  {{- $name := ( include "common.fullname.dbaasha" . ) -}}
  {{- printf "statefulset-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.containername.dbaasha.redis" -}}
  {{- $name := ( include "common.fullname.dbaasha" . ) -}}
  {{- printf "container-%s-redis" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.containername.dbaasha.sentinel" -}}
  {{- $name := ( include "common.fullname.dbaasha" . ) -}}
  {{- printf "container-%s-sentinel" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}



{{- define "common.serviceaccountname.dbaasha" -}}
  {{- $name := ( include "common.fullname.dbaasha" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.dbaasha.tcp" -}}
  {{- $name := ( include "common.fullname.dbaasha" . ) -}}
  {{- printf "service-%s-tcp" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceport.dbaasha.redis" -}}6379{{- end -}}
{{- define "common.serviceport.dbaasha.sentinel" -}}26379{{- end -}}
