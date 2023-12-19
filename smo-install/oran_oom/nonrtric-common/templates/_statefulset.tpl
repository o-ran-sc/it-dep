{{- define "common.vardataVolumeClaimTemplate" -}}
- metadata:
    name: {{ include "common.name" . }}-vardata
  spec:
    accessModes: [ ReadWriteOnce ]
    storageClassName: "{{ .Values.persistence.storageClassName }}"
    resources:
      requests:
        storage: "{{ .Values.persistence.size }}"
{{- end -}}

{{- define "common.vardataMountName" -}}
{{ include "common.name" . }}-vardata
{{- end -}}
