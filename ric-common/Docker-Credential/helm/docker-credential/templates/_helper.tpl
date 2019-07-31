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
  Resolve the image repository secret token.
  The value for .Values.global.repositoryCred is used:
  repositoryCred:
    user: user
    password: password
    mail: email (optional)
*/}}
{{- define "repository.secret" -}}
  {{- $repo := .Values.repository }}
  {{- $cred := .Values.repositoryCredential }}
  {{- $user := default "docker" $cred.user }}
  {{- $password := default "docker" $cred.password }}
  {{- $mail := default "@" $cred.mail }}
  {{- $auth := printf "%s:%s" $user $password | b64enc }}
  {{- printf "{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}" $repo $user $password $mail $auth | b64enc -}}
{{- end -}}

