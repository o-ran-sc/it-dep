#######################################################################
#   Copyright (c) 2019 AT&T Intellectual Property.
#   Copyright (c) 2019 Nokia.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#########################################################################
FROM alpine

MAINTAINER "RIC"

LABEL name="Generic initcontainer image for RIC Platform components"

RUN apk update

# iproute2: required for e2 termination
RUN apk add iproute2
# kubectl: required for xapp/ricplt helm installers
RUN apk add openssl
# kubectl: required for xapp/ricplt helm installers
ADD https://storage.googleapis.com/kubernetes-release/release/v1.14.1/bin/linux/amd64/kubectl /bin/kubectl
RUN chmod +x /bin/kubectl

COPY bin/ricplt-init.sh /ricplt-init.sh

#
CMD /ricplt-init.sh
