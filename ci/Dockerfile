FROM ubuntu:18.04
RUN apt-get update && apt-get -y install curl
RUN curl -L https://git.io/get_helm.sh | bash
RUN helm init -c
ARG TGT=/tmp/it-dep
COPY . $TGT
RUN rm -f /tmp/ric-common*tgz
RUN helm package -d /tmp $TGT/ric-common/Common-Template/helm/ric-common
RUN find $TGT -name Chart.yaml -printf '%h\n' | xargs -n 1 $TGT/ci/helm-lint-template.sh | tee out
RUN grep -q -i error out && exit 1
