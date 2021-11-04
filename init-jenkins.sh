#!/bin/sh

mkdir $HOME/jenkins
sudo chgrp docker $HOME/jenkins
sudo chown -R floobot:docker $HOME/jenkins

docker network create jenkins
docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume $HOME/jenkins/jenkins-docker-certs:/certs/client \
  --volume $HOME/jenkins/jenkins-home:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2

docker build -t custom-jenkins:0.1 .

docker run \
  --name custom-jenkins \
  --rm \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume $HOME/jenkins/jenkins-home:/var/jenkins_home \
  --volume $HOME/jenkins/jenkins-docker-certs:/certs/client:ro \
  custom-jenkins:0.1
