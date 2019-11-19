############################################################################
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
############################################################################
FROM alpine

MAINTAINER "RIC"

LABEL name="A container with support for creating Kubernetes SSL secrets"

RUN apk update

RUN apk add openssl

# unfortunately not available by itself in apk
ADD https://storage.googleapis.com/kubernetes-release/release/v1.14.1/bin/linux/amd64/kubectl /bin/kubectl
RUN chmod +x /bin/kubectl

COPY bin/cert-gen.sh /bin/cert-gen.sh
COPY bin/svcacct-to-kubeconfig.sh /bin/svcacct-to-kubeconfig.sh
COPY bin/tls-secrets.sh /tls-secrets.sh

RUN mkdir /pki

CMD /tls-secrets.sh

