#!/bin/sh

mkdir $HOME/jenkins
sudo chgrp staff $HOME/jenkins
sudo chown -R $(whoami):staff $HOME/jenkins

docker network create jenkins
docker run \
  --restart unless-stopped \
  --name jenkins-docker \
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
  --restart unless-stopped \
  --name custom-jenkins \
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

echo "Admin Password"
echo $(docker exec custom-jenkins cat /var/jenkins_home/secrets/initialAdminPassword)
