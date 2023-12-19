{{- define "dmaapTopic.initContainer" -}}
- name: dmaap-topic-init
  image: alpine:latest
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
