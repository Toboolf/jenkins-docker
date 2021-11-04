#!/bin/sh

docker stop custom-jenkins
docker stop jenkins-docker

docker rm jenkins-docker
docker rm custom-jenkins

docker rmi custom-jenkins:0.1
