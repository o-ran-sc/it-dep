#!/bin/bash






curl -u admin:admin123 -X POST -H "Content-Type: application/json" --data '{"name":"create_docker_repo","type":"groovy","content":"repository.createDockerHosted('\''docker.snapshot'\'', 10001, null, '\''default'\'', false, true)"}' http://nexus.ricaux.local:30000/service/rest/v1/script

curl -u admin:admin123 -X POST -H 'Content-Type: text/plain' -H 'Accept: application/json' 'http://nexus.ricaux.local:30000/service/rest/v1/script/create_docker_repo/run'


cp /tmp/tls.crt  /etc/docker/certs.d/docker.ricaux.local:31000/ca.crt

docker login -u admin -p admin123 docker.ricaux.local:31000
