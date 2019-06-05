# add rancodev CI tool hostnames
if [ ! -z "${__RUNRICENV_GERRIT_IP__}" ]; then
  echo "${__RUNRICENV_GERRIT_IP__} ${__RUNRICENV_GERRIT_HOST__}" >> /etc/hosts
fi

if [ ! -z "${__RUNRICENV_DOCKER_IP__}" ]; then
  echo "${__RUNRICENV_DOCKER_IP__} ${__RUNRICENV_DOCKER_HOST__}" >> /etc/hosts

  if [ ! -z "${__RUNRICENV_DOCKER_CERT__}" ]; then
    mkdir -p /etc/docker/certs.d/${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}
    cat <<EOF >/etc/docker/ca.crt
${__RUNRICENV_DOCKER_CERT__}
EOF
    cp /etc/docker/ca.crt \
       /etc/docker/certs.d/${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}/ca.crt
  fi

  service docker restart
  systemctl enable docker.service
  docker login -u ${__RUNRICENV_DOCKER_USER__} -p ${__RUNRICENV_DOCKER_PASS__} \
    ${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}
  docker pull ${__RUNRICENV_DOCKER_HOST__}:${__RUNRICENV_DOCKER_PORT__}/whoami:0.0.1
fi


if [ ! -z "${__RUNRICENV_HELMREPO_IP__}" ]; then
  echo "${__RUNRICENV_HELMREPO_IP__} ${__RUNRICENV_HELMREPO_HOST__}" >> /etc/hosts
  if [ ! -z "${__RUNRICENV_HELMREPO_CERT__}" ]; then
    cat <<EOF >/etc/ca-certificates/update.d/helm.crt
${__RUNRICENV_HELMREPO_CERT__}
EOF
  fi
fi

