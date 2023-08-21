#!/usr/bin/env bash
#+--------------------------------------------------------------------------------+
#|                                                                                |
#|          @author Juan Francisco Alvarez Urquijo <paco@technogi.com.mx>         |
#|                                                                                |
#|                                                                                |
#+--------------------------------------------------------------------------------+

set -e

# @see http://stackoverflow.com/questions/1682442/reading-java-properties-file-from-bash
version=$(./findProperty.sh version ../gradle.properties)
#version=${version#\'}
#version=${version%\'}

DOCKER_IP=$(docker info --format "{{.Swarm.NodeAddr}}")

docker run --name ms-articulos-microservice --hostname ms-articulos-microservice -it --rm \
	-p 6004:8080 \
	-e SPRING_CLOUD_CONFIG_URI="http://${DOCKER_IP}:8888" \
	-e SPRING_CLOUD_CONFIG_USERNAME="config" \
	-e SPRING_CLOUD_CONFIG_PASSWORD="secret" \
	-e SPRING_RABBITMQ_HOST=${DOCKER_IP} \
	-e SPRING_RABBITMQ_PORT=5672 \
	-e SPRING_RABBITMQ_USERNAME="user" \
	-e SPRING_RABBITMQ_PASSWORD="password" \
	-e SPRING_PROFILES_ACTIVE="docker-local" \
	203593945322.dkr.ecr.us-east-1.amazonaws.com/microsip/ms-articulos-microservice:${version}

# Send Message to Event Bus for Microservices Configuration Update
# curl http://localhost:8888/monitor -d path="*"
