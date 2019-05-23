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

ARG NEXUS_VERSION=3.15.2
ARG NEXUS_BUILD=01

FROM maven:3-jdk-8-alpine AS aptbuild
#ARG NEXUS_VERSION=3.14.0
#ARG NEXUS_BUILD=04

COPY ./nexus-repository-apt /nexus-repository-apt/
#RUN cd /nexus-repository-apt/; sed -i "s/3.15.2-01/${NEXUS_VERSION}-${NEXUS_BUILD}/g" pom.xml; \
#    mvn;
RUN cd /nexus-repository-apt/; mvn;


FROM maven:3-jdk-8-alpine AS helmbuild
ARG NEXUS_VERSION=3.15.2
ARG NEXUS_BUILD=01

COPY ./nexus-repository-helm /nexus-repository-helm/
RUN cd /nexus-repository-helm/; sed -i "s/3.14.0-04/${NEXUS_VERSION}-${NEXUS_BUILD}/g" pom.xml; \
    mvn clean package;




FROM sonatype/nexus3:$NEXUS_VERSION
ARG NEXUS_VERSION=3.15.2
ARG NEXUS_BUILD=01
# Will not seem to work in sed without some magick
ARG APT_VERSION=1.0.10
ARG COMP_VERSION=1.18
#ARG COMP_VERSION=1.16.1
ARG XZ_VERSION=1.8
ARG APT_TARGET=/opt/sonatype/nexus/system/net/staticsnow/nexus-repository-apt/${APT_VERSION}/
ARG HELM_VERSION=0.0.7
ARG TARGET_DIR=/opt/sonatype/nexus/system/org/sonatype/nexus/plugins/nexus-repository-helm/${HELM_VERSION}/
USER root
RUN mkdir -p ${APT_TARGET}; \
    sed -i "s@nexus-repository-maven</feature>@nexus-repository-maven</feature>\n        <feature version=\"${APT_VERSION}\" prerequisite=\"false\" dependency=\"false\">nexus-repository-apt</feature>@g" /opt/sonatype/nexus/system/org/sonatype/nexus/assemblies/nexus-core-feature/${NEXUS_VERSION}-${NEXUS_BUILD}/nexus-core-feature-${NEXUS_VERSION}-${NEXUS_BUILD}-features.xml; \
    sed -i "s@<feature name=\"nexus-repository-maven\"@<feature name=\"nexus-repository-apt\" description=\"net.staticsnow:nexus-repository-apt\" version=\"${APT_VERSION}\">\n        <details>net.staticsnow:nexus-repository-apt</details>\n        <bundle>mvn:net.staticsnow/nexus-repository-apt/${APT_VERSION}</bundle>\n        <bundle>mvn:org.apache.commons/commons-compress/${COMP_VERSION}</bundle>\n        <bundle>mvn:org.tukaani/xz/${XZ_VERSION}</bundle>\n    </feature>\n    <feature name=\"nexus-repository-maven\"@g" /opt/sonatype/nexus/system/org/sonatype/nexus/assemblies/nexus-core-feature/${NEXUS_VERSION}-${NEXUS_BUILD}/nexus-core-feature-${NEXUS_VERSION}-${NEXUS_BUILD}-features.xml;
COPY --from=aptbuild /nexus-repository-apt/target/nexus-repository-apt-${APT_VERSION}.jar ${APT_TARGET}
RUN mkdir -p ${TARGET_DIR}; \
    sed -i 's@nexus-repository-maven</feature>@nexus-repository-maven</feature>\n        <feature prerequisite="false" dependency="false">nexus-repository-helm</feature>@g' /opt/sonatype/nexus/system/org/sonatype/nexus/assemblies/nexus-core-feature/${NEXUS_VERSION}-${NEXUS_BUILD}/nexus-core-feature-${NEXUS_VERSION}-${NEXUS_BUILD}-features.xml; \
    sed -i 's@<feature name="nexus-repository-maven"@<feature name="nexus-repository-helm" description="org.sonatype.nexus.plugins:nexus-repository-helm" version="0.0.7">\n        <details>org.sonatype.nexus.plugins:nexus-repository-helm</details>\n        <bundle>mvn:org.sonatype.nexus.plugins/nexus-repository-helm/0.0.7</bundle>\n        <bundle>mvn:org.apache.commons/commons-compress/1.18</bundle>\n   </feature>\n    <feature name="nexus-repository-maven"@g' /opt/sonatype/nexus/system/org/sonatype/nexus/assemblies/nexus-core-feature/${NEXUS_VERSION}-${NEXUS_BUILD}/nexus-core-feature-${NEXUS_VERSION}-${NEXUS_BUILD}-features.xml;
COPY --from=helmbuild /nexus-repository-helm/target/nexus-repository-helm-${HELM_VERSION}.jar ${TARGET_DIR}
USER nexus
