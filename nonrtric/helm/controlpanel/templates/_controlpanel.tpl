################################################################################
#   Copyright (c) 2020 Nordix Foundation.                                      #
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

{{- define "common.name.controlpanel" -}}
  {{- printf "controlpanel" -}}
{{- end -}}

{{- define "common.namespace.nonrtric" -}}
  {{- printf "nonrtric" -}}
{{- end -}}

{{- define "common.fullname.controlpanel" -}}
  {{- $name := ( include "common.name.controlpanel" . ) -}}
  {{- $namespace := ( include "common.namespace.nonrtric" . ) -}}
  {{- printf "%s-%s" $namespace $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configmapname.controlpanel" -}}
  {{- $name := ( include "common.fullname.controlpanel" . ) -}}
  {{- printf "configmap-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.deploymentname.controlpanel" -}}
  {{- $name := ( include "common.fullname.controlpanel" . ) -}}
  {{- printf "deployment-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.containername.controlpanel" -}}
  {{- $name := ( include "common.fullname.controlpanel" . ) -}}
  {{- printf "container-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.servicename.controlpanel.http" -}}
  {{- $name := ( include "common.fullname.controlpanel" . ) -}}
  {{- printf "service-%s-http" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.serviceport.controlpanel.http" -}}30090{{- end -}}

{{- define "common.serviceport.controlpanel.container" -}}8080{{- end -}}