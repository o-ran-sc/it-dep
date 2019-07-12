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
  This file defines the port numbers various components expose.

  To ensure compatibility when switching between ClusterIP and headless service
  types, the service port and container port must be the same.

  For inter-component communications, the sender shall use 
  {{ include "common.serviceport.XXXX" . }} template in its chart to
  configure the destination port.  The receiver side MUST keep the
  port numbers consistent with the ports that the container code implements.
*/}}

{{- define "common.serviceport.e2term.rmr.data" -}}38000{{- end -}}
{{- define "common.serviceport.e2term.rmr.route" -}}4561{{- end -}}
{{- define "common.serviceport.e2term.http" -}}8080{{- end -}}
{{- define "common.serviceport.e2term.sctp" -}}5577{{- end -}}


{{- define "common.serviceport.e2mgr.rmr.data" -}}3801{{- end -}}
{{- define "common.serviceport.e2mgr.rmr.route" -}}4561{{- end -}}
{{- define "common.serviceport.e2mgr.http" -}}3800{{- end -}}

{{- define "common.serviceport.a1mediator.rmr.data" -}}4562{{- end -}}
{{- define "common.serviceport.a1mediator.rmr.route" -}}4561{{- end -}}
{{- define "common.serviceport.a1mediator.http" -}}10000{{- end -}}

{{- define "common.serviceport.rtmgr.rmr.data" -}}4560{{- end -}}
{{- define "common.serviceport.rtmgr.rmr.route" -}}4561{{- end -}}
{{- define "common.serviceport.rtmgr.http" -}}3800{{- end -}}

{{- define "common.serviceport.submgr.rmr.data" -}}4560{{- end -}}
{{- define "common.serviceport.submgr.rmr.route" -}}4561{{- end -}}
{{- define "common.serviceport.submgr.http" -}}3800{{- end -}}

{{- define "common.serviceport.appmgr.rmr.data" -}}4560{{- end -}}
{{- define "common.serviceport.appmgr.rmr.route" -}}4561{{- end -}}
{{- define "common.serviceport.appmgr.http" -}}8080{{- end -}}

{{- define "common.serviceport.nexus.http" -}}8080{{- end -}}

{{- define "common.serviceport.dashboard.http" -}}30080{{- end -}}

{{- define "common.serviceport.dbaas.tcp" -}}6379{{- end -}}

{{- define "common.serviceport.messagerouter.tcp" -}}3904{{- end -}}

{{- define "common.serviceport.ves.tcp" -}}8080{{- end -}}
