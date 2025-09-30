{{/*
################################################################################
#   Copyright (c) 2025 OpenInfra Foundation Europe.                            #
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
*/}}

{{- define "repository.nexusRepo" -}}
  {{- $repoKey := .repoKey | required "repoKey is required" -}}
  {{- $default := .default | default "" -}}
  {{- $dot := .dot | default . -}}
  {{- $values := $dot.Values | default (dict) -}}
  {{- $localValue := get $values $repoKey | default "" -}}
  {{- $globalValue := get ($values.global | default (dict)) $repoKey | default "" -}}
  {{- coalesce $localValue $globalValue $default -}}
{{- end -}}

{{- define "repository.nexusProxyRepo" -}}
  {{- include "repository.nexusRepo" (dict "dot" . "repoKey" "nexusProxyRepo" "default" "nexus3.o-ran-sc.org:10001") -}}
{{- end -}}

{{- define "repository.nexusReleaseRepo" -}}
  {{- include "repository.nexusRepo" (dict "dot" . "repoKey" "nexusReleaseRepo" "default" "nexus3.o-ran-sc.org:10002") -}}
{{- end -}}

{{- define "repository.nexusSnapshotRepo" -}}
  {{- include "repository.nexusRepo" (dict "dot" . "repoKey" "nexusSnapshotRepo" "default" "nexus3.o-ran-sc.org:10003") -}}
{{- end -}}

{{- define "repository.nexusStagingRepo" -}}
  {{- include "repository.nexusRepo" (dict "dot" . "repoKey" "nexusStagingRepo" "default" "nexus3.o-ran-sc.org:10004") -}}
{{- end -}}
