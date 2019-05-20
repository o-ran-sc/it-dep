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

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ricapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ricapp.fullname" -}}
{{- if .Values.ricapp.fullnameOverride -}}
{{- .Values.ricapp.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.ricapp.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ricapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "repository" -}}
  {{- default "docker.ricinfra.local:80" .Values.repository -}}
{{- end -}}

{{/*
  Resolve the image repository secret token.
  The value for .Values.global.repositoryCred is used:
  repositoryCred:
    user: user
    password: password
    mail: email (optional)
*/}}
{{- define "repository.secret" -}}
  {{- $repo := include "repository" . }}
  {{- $cred := .Values.repositoryCred }}
  {{- $user := default "docker" $cred.user }}
  {{- $password := default "docker" $cred.password }}
  {{- $mail := default "@" $cred.mail }}
  {{- $auth := printf "%s:%s" $user $password | b64enc }}
  {{- printf "{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}" $repo $user $password $mail $auth | b64enc -}}
{{- end -}}


{{- define "helmrepo.secret.user" -}}
  {{- $user := default "helm" .Values.helmrepoCred.user -}}
  {{- printf "%s" $user |b64enc }}
{{- end -}}


{{- define "helmrepo.secret.password" -}}
  {{- $pass := default "helm" .Values.helmrepoCred.password -}}
  {{- printf "%s" $pass |b64enc }}
{{- end -}}
