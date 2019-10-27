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

{{- define "common.serviceport.e2mgr.rmr.data" -}}3801{{- end -}}
{{- define "common.serviceport.e2mgr.rmr.route" -}}4561{{- end -}}
{{- define "common.serviceport.e2mgr.http" -}}3800{{- end -}}

{{- define "common.serviceport.rsm.rmr.data" -}}4801{{- end -}}
{{- define "common.serviceport.rsm.rmr.route" -}}4561{{- end -}}
{{- define "common.serviceport.rsm.http" -}}4800{{- end -}}

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

{{- define "common.serviceport.vespamgr.http" -}}8080{{- end -}}

{{- define "common.serviceport.jaegeradapter.zipkincompact" -}}5775{{- end -}}
{{- define "common.serviceport.jaegeradapter.jaegercompact" -}}6831{{- end -}}
{{- define "common.serviceport.jaegeradapter.jaegerbinary" -}}6832{{- end -}}
{{- define "common.serviceport.jaegeradapter.httpquery" -}}16686{{- end -}}
{{- define "common.serviceport.jaegeradapter.httpconfig" -}}5778{{- end -}}
{{- define "common.serviceport.jaegeradapter.zipkinhttp" -}}9411{{- end -}}
{{- define "common.serviceport.jaegeradapter.jaegerhttp" -}}14268{{- end -}}
{{- define "common.serviceport.jaegeradapter.jaegerhttpt" -}}14267{{- end -}}
 
{{- define "common.portname.jaegeradapter.zipkincompact" -}}"zipkincompact"{{- end -}}
{{- define "common.portname.jaegeradapter.jaegercompact" -}}"jaegercompact"{{- end -}}
{{- define "common.portname.jaegeradapter.jaegerbinary" -}}"jaegerbinary"{{- end -}}
{{- define "common.portname.jaegeradapter.zipkinhttp" -}}"zipkinhttp"{{- end -}}
{{- define "common.portname.jaegeradapter.jaegerhttp" -}}"jaegerhttp"{{- end -}}
{{- define "common.portname.jaegeradapter.jaegerhttpt" -}}"jaegerhttpt"{{- end -}}
{{- define "common.portname.jaegeradapter.httpquery" -}}"httpquery"{{- end -}}
{{- define "common.portname.jaegeradapter.httpconfig" -}}"httpconfig"{{- end -}}




{{- define "common.serviceport.nexus.http" -}}8080{{- end -}}

{{- define "common.serviceport.chartmuseum.http" -}}8080{{- end -}}

{{- define "common.serviceport.dashboard.http" -}}30080{{- end -}}
{{- define "common.serviceport.dashboard.container" -}}8080{{- end -}}

{{- define "common.serviceport.dbaas.tcp" -}}6379{{- end -}}

{{- define "common.serviceport.messagerouter.http" -}}3904{{- end -}}
{{- define "common.serviceport.messagerouter.https" -}}3905{{- end -}}
{{- define "common.serviceport.messagerouter.kafka" -}}9092{{- end -}}
{{- define "common.serviceport.messagerouter.zookeeper" -}}2181{{- end -}}

{{- define "common.serviceport.ves.http" -}}8080{{- end -}}
{{- define "common.serviceport.ves.https" -}}8443{{- end -}}
