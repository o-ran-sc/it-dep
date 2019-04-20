################################################################################
#   Copyright (c) 2019 AT&T Intellectual Property.                             #
#   Copyright (c) 2019 Nokia.                                                  #
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

{{/*
  Resolve the name of the common helm repository.
  The value for .Values.helmRepository is used by default,
  unless either override mechanism is used.

  - .Values.global.helmRepository  : override default helm repository for all components that use helm
  - .Values.helmRepositoryOverride : override global and default helm repository on a per component base
*/}}
{{- define "common.helmrepository" -}}
  {{- if .Values.helmRepositoryOverride -}}
    {{- printf "%s" .Values.helmRepositoryOverride -}}
  {{- else -}}
    {{- if  .Values.global -}}
      {{- if .Values.global.helmRepository -}}
        {{- printf "%s" .Values.global.helmRepository -}}
      {{- else -}}
        {{- printf "%s" .Values.helmRepository -}}
      {{- end -}}
    {{- else -}}
      {{- printf "%s" .Values.helmRepository -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
  Resolve the helm repository secret token.
  The secret token should be installed by K8S system admin.
  The value for .Values.helmRepositoryCred is used by default,
  unless either override mechanism is used.

  - .Values.global.helmRepositoryCred  : override default helm repository credential
  - .Values.helmRepositoryCredOverride : override global and default helm repository credential
*/}}
{{- define "common.helmrepositorycred" -}}
  {{- if .Values.helmRepositoryCredOverride -}}
    {{- printf "%s" .Values.helmRepositoryCredOverride -}}
  {{- else -}}
    {{- if  .Values.global -}}
      {{- if .Values.global.helmRepositoryCred -}}
        {{- printf "%s" .Values.global.helmRepositoryCred -}}
      {{- else -}}
        {{- printf "%s" .Values.helmRepositoryCred -}}
      {{- end -}}
    {{- else -}}
      {{- printf "%s" .Values.helmRepositoryCred -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Resolve the helm repository certificate.
  The certificate should be installed by K8S system admin.
  The value for .Values.helmRepositoryCert is used by default,
  unless either override mechanism is used.

  - .Values.global.helmrepositoryCert  : override default helm repository certificate
  - .Values.helmRepositoryCertOverride : override global and default helm repository certificate
*/}}
{{- define "common.helmrepositorycert" -}}
  {{- if .Values.helmRepositoryCertOverride -}}
    {{- printf "%s" .Values.helmRepositoryCertOverride -}}
  {{- else -}}
    {{- if  .Values.global -}}
      {{- if .Values.global.helmRepositoryCert -}}
        {{- printf "%s" .Values.global.helmRepositoryCert -}}
      {{- else -}}
        {{- printf "%s" .Values.helmRepositoryCert -}}
      {{- end -}}
    {{- else -}}
      {{- printf "%s" .Values.helmRepositoryCert -}}
    {{- end -}}
  {{- end -}}
{{- end -}}



{{/*
Generate certificates for the helm repo
*/}}
{{- define "common.helmrepository.gen-certs" -}}
{{- $altNames := list ( printf "helm.%s" .Values.ingress.hostpostfix ) -}}
{{- $ca := genCA "helm-repository-ca" 365 -}}
{{- $cert := genSignedCert ( include "nexus.name" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

