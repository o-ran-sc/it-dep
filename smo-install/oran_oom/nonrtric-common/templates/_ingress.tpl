{{- define "common.ingressClassName" -}}
  {{- if and .Values.global .Values.global.ingress -}}
    {{- default "kong" .Values.global.ingress.ingressClass -}}
  {{- else -}}
    {{- print "kong" -}}
  {{- end -}}
{{- end -}}

{{- define "common.ingressEnabled" -}}
  {{- if and .Values.global .Values.global.ingress -}}
    {{- if .Values.global.ingress.enabled -}}
      {{- if or .Values.global.ingress.enabled_all .Values.ingress.enabled -}}
  true
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- .Values.ingress.enabled -}}
  {{- end -}}
{{- end -}}
