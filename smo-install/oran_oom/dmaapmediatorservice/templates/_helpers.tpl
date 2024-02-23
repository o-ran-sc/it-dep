{{/*
################################################################################
#   Copyright (c) 2024 NYCU WINLab.                                            #
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

{{- define "dmaapTopic.initContainer" -}}
- name: dmaap-topic-init
  image: alpine:3.19.1
  command:
  - sh
  - -c
  - apk add --no-cache curl jq; sh /app/dmaap-topic-init.sh;
  volumeMounts:
  - name: dmaap-topic-init
    mountPath: /app
{{- end -}}

{{- define "dmaapTopic.initConfigMap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.name" . }}-dmaap-topic-init
  namespace: {{ include "common.namespace" . }}
  labels: {{- include "common.labels" . | nindent 4 }}
data:
  dmaap-topic-init.sh: |
    {{- tpl (.Files.Get "resources/dmaap-topic-init.sh") . | nindent 4 }}
{{- end }}

{{- define "dmaapTopic.initVolume" -}}
- name: dmaap-topic-init
  configMap:
    name: {{ include "common.name" . }}-dmaap-topic-init
{{- end }}
