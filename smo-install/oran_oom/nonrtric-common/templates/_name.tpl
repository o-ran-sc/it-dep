{{/*
# Copyright © 2017 Amdocs, Bell Canada
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
*/}}

{{/*
  Expand the name of a chart.
  The function takes from one to two arguments (inside a dictionary):
     - .dot : environment (.)
     - .suffix : add a suffix to the name
*/}}
{{- define "common.name" -}}
  {{- $dot := default . .dot -}}
  {{- $suffix := .suffix -}}
  {{- default (default $dot.Chart.Name $dot.Values.nameOverride) .nameOverride | trunc 63 | trimSuffix "-" -}}{{ if $suffix }}{{ print "-" $suffix }}{{ end }}
{{- end -}}

{{- define "common.containername" -}}
  {{- $name := ( include "common.name" . ) -}}
  {{- printf "container-%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.release" -}}
{{ .Release.Name }}
{{- end -}}