{{- define "common.applicationConfigmap" -}}
{{- $dot := default . .dot -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.name" $dot }}-application-configmap
  namespace: {{ include "common.namespace" . }}
  labels: {{- include "common.labels" . | nindent 4 }}
data:
  application.yml: |
    {{- toYaml .Values.application | nindent 4 }}
{{ end -}}
