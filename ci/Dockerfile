##############################################################################
#
#   Copyright (c) 2019 AT&T Intellectual Property.
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
#
##############################################################################
FROM ubuntu:18.04
RUN apt-get update && apt-get -y install curl ca-certificates wget
ARG HELMVERSION=v2.17.0
# often times out during LF jenkins build
RUN wget https://get.helm.sh/helm-${HELMVERSION}-linux-amd64.tar.gz && tar -xvf ../helm-${HELMVERSION}-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm
RUN helm init -c --skip-repos
ARG TGT=/tmp/it-dep
COPY . $TGT
# Remove the smo-install as this one will be verified in another verify job
RUN rm -rf $TGT/smo-install
RUN $TGT/bin/verify-ric-charts
