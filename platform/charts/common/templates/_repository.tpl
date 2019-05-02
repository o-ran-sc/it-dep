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
  Resolve the name of the common image repository.
  The value for .Values.repository is used by default,
  unless either override mechanism is used.

  - .Values.global.repository  : override default image repository for all images
  - .Values.repositoryOverride : override global and default image repository on a per image basis
*/}}
{{- define "common.repository" -}}
  {{- if .Values.repositoryOverride -}}
    {{- printf "%s" .Values.repositoryOverride -}}
  {{- else -}}
    {{- if .Values.global -}}
      {{- if .Values.global.repository -}}
        {{- printf "%s" .Values.global.repository -}}
      {{- else -}}
        {{- printf "%s" .Values.repository -}}
      {{- end -}}
    {{- else -}}
      {{- printf "%s" .Values.repository -}}
    {{- end -}}  
  {{- end -}}
{{- end -}}


{{/*
  Resolve the docker image repository secret token configmap.
  The secret token should be installed by K8S system admin.
  The value for .Values.repositoryCred is used by default,
  unless either override mechanism is used.

  - .Values.global.repositoryCred  : override default docker registry credential
  - .Values.repositoryCredOverride : override global and default docker registry credential
*/}}
{{- define "common.repositoryCred" -}}
  {{- if .Values.repositoryCredOverride -}}
    {{- printf "%s" .Values.repositoryCredOverride -}}
  {{- else -}}
    {{- if  .Values.global -}}
      {{- if .Values.global.repositoryCred -}}
        {{- printf "%s" .Values.global.repositoryCred -}}
      {{- else -}}
	{{- printf "%s" .Values.repositoryCred -}}
      {{- end -}}
    {{- else -}}
      {{- printf "%s" .Values.repositoryCred -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
  Define the golbal image pull policy.
  The value for .Values.imagePullPolicy is used by default,
  unless either override mechanism is used.

  - .Values.global.imagePullPolicy  : override default pull policy
  - .Values.imagePullPolicyOverride : override global and default pull policy
*/}}
{{- define "common.pullPolicy" -}}
  {{- if .Values.imagePullPolicyOverride -}}
    {{- printf "%s" .Values.imagePullPolicyOverride -}}
  {{- else -}}
    {{- if  .Values.global -}}
      {{- if .Values.global.imagePullPolicy -}}
        {{- printf "%s" .Values.global.imagePullPolicy -}}
      {{- else -}}
        {{- printf "%s" .Values.imagePullPolicy -}}
      {{- end -}}
    {{- else -}}
      {{- printf "%s" .Values.imagePullPolicy -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
  Resolve the docker registry certificate name.
  The value for .Values.repositoryCert is used by default,
  unless either override mechanism is used.

  - .Values.global.repositoryCert  : override default repository certificate
  - .Values.repositoryCertOverride : override global and default repository certificate
*/}}
{{- define "common.repositorycert" -}}
  {{- if .Values.repositoryCertOverride -}}
    {{- printf "%s" .Values.repositoryCertOverride -}}
  {{- else -}}
    {{- if  .Values.global -}}
      {{- if .Values.global.repositoryCert -}}
        {{- printf "%s" .Values.global.repositoryCert -}}
      {{- else -}}
        {{- printf "%s" .Values.repositoryCert -}}
      {{- end -}}
    {{- else -}}
      {{- printf "%s" .Values.repositoryCert -}}
    {{- end -}}
  {{- end -}}
{{- end -}}






{{/*
Generate certificates for the docker registry
*/}}
{{- define "common.repository.gen-certs" -}}
{{- $altNames := list ( printf "docker.%s" .Values.ingress.hostpostfix ) -}}
{{- $ca := genCA "docker-registry-ca" 365 -}}
{{- $cert := genSignedCert ( include "nexus.name" . ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}
