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

{{- define "common.name.alarmadapter" -}}
  {{- printf "alarmadapter" -}}
{{- end -}}

{{- define "common.fullname.alarmadapter" -}}
  {{- $name := ( include "common.name.alarmadapter" . ) -}}
  {{- $namespace := ( include "common.namespace.platform" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.alarmadapter" -}}
  {{- $name := ( include "common.fullname.alarmadapter" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.deploymentname.alarmadapter" -}}
  {{- $name := ( include "common.fullname.alarmadapter" . ) -}}
  {{- printf "deployment-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.containername.alarmadapter" -}}
  {{- $name := ( include "common.fullname.alarmadapter" . ) -}}
  {{- printf "container-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceaccountname.alarmadapter" -}}
  {{- $name := ( include "common.fullname.alarmadapter" . ) -}}
  {{- printf "svcacct-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.ingressname.alarmadapter" -}}
  {{- $name := ( include "common.fullname.alarmadapter" . ) -}}
  {{- printf "ingress-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.alarmadapter.rmr" -}}
  {{- $name := ( include "common.fullname.alarmadapter" . ) -}}
  {{- printf "service-%s-rmr" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.alarmadapter.http" -}}
  {{- $name := ( include "common.fullname.alarmadapter" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceport.alarmadapter.rmr.data" -}}4560{{- end -}}
{{- define "common.serviceport.alarmadapter.rmr.route" -}}4561{{- end -}}
{{- define "common.serviceport.alarmadapter.http" -}}8080{{- end -}}
