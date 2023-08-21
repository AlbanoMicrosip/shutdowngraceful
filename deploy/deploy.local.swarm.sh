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

docker service create --name ms-articulos-microservice --hostname ms-articulos-microservice \
	--network skynet --replicas 1 \
	--secret source=spring.cloud.config.uri,target=spring.cloud.config.uri \
	--secret source=spring.cloud.config.username,target=spring.cloud.config.username \
	--secret source=spring.cloud.config.password,target=spring.cloud.config.password \
	--secret source=spring.rabbitmq.username,target=spring.rabbitmq.username \
	--secret source=spring.rabbitmq.password,target=spring.rabbitmq.password \
	-e SPRING_CLOUD_CONFIG_URI_FILE="/run/secrets/spring.cloud.config.uri" \
	-e SPRING_CLOUD_CONFIG_USERNAME_FILE="/run/secrets/spring.cloud.config.username" \
	-e SPRING_CLOUD_CONFIG_PASSWORD_FILE="/run/secrets/spring.cloud.config.password" \
	-e SPRING_RABBITMQ_HOST=rabbitmq \
	-e SPRING_RABBITMQ_PORT=5672 \
	-e SPRING_RABBITMQ_USERNAME_FILE="/run/secrets/spring.rabbitmq.username" \
	-e SPRING_RABBITMQ_PASSWORD_FILE="/run/secrets/spring.rabbitmq.password" \
	--with-registry-auth \
	203593945322.dkr.ecr.us-east-1.amazonaws.com/microsip/ms-articulos-microservice:${version}
##--constraint 'node.role == manager' \

# Send Message to Event Bus for Microservices Configuration Update
# curl http://localhost:8888/monitor -d path="*"