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
  {{if .Values.repositoryOverride }}
    {{- printf "%s" .Values.repositoryOverride -}}
  {{else}}
    {{- default .Values.repository .Values.global.repository -}}
  {{end}}
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
  {{- $repo := default "${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}" $repo }}
  {{- $cred := .Values.global.repositoryCred }}
  {{- $mail := default "@" $cred.mail }}
  {{- $auth := printf "%s:%s" $cred.user $cred.password | b64enc }}
  {{- printf "{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}" $repo $cred.user $cred.password $mail $auth | b64enc -}}
{{- end -}}

