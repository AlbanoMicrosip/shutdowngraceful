#!/usr/bin/env bash
#+--------------------------------------------------------------------------------+
#|                                                                                |
#|          @author Juan Francisco Alvarez Urquijo <paco@technogi.com.mx>         |
#|                                                                                |
#|                                                                                |
#+--------------------------------------------------------------------------------+

set -e

if [[ -z $SERVICE_NAME ]]; then
	echo "Define Service Name"
	echo "Example: export SERVICE_NAME=ms-articulos-microservice"
	exit -1
elif [[ -z $SERVICE_VERSION ]]; then
	echo "Define Service Version"
	echo "Example: export SERVICE_VERSION=0.0.1"
	exit -1
elif [[ -z $MICROSIP_DOCKER_REGISTRY ]]; then
	echo "Define Docker Registry"
	echo "Example: export MICROSIP_DOCKER_REGISTRY=203593945322.dkr.ecr.us-east-1.amazonaws.com/microsip"
	exit -1
elif [[ -z $DOCKER_IMAGE_NAME ]]; then
	echo "Define Docker Image Name"
	echo "Example: export DOCKER_IMAGE_NAME=ms-articulos-microservice"
	exit -1
elif [[ -z $DOCKER_EXPOSED_PORT ]]; then
	echo "Define Docker Service Exposed Port"
	echo "Example: export DOCKER_EXPOSED_PORT=8080"
	exit -1
elif [[ -z $REPLICAS ]]; then
	echo "Define Number of Replicas for Service"
	echo "Example: export REPLICAS=1"
	exit -1
elif [[ -z $DOCKER_NETWORKS ]]; then
	echo "Define Docker Network for Service"
	echo "Example: export DOCKER_NETWORKS='--network skynet --network mongo'"
	exit -1
elif [[ -z $UPDATE_DELAY ]]; then
	echo "Define Replica Update Delay"
	echo "Example: export UPDATE_DELAY=10s"
	exit -1
elif [[ -z $UPDATE_PARALLELISM ]]; then
	echo "Define Replica Update Parallelism"
	echo "Example: export UPDATE_PARALLELISM=1"
	exit -1
elif [[ -z $SPRING_PROFILES_ACTIVE ]]; then
	echo "Define Spring Profiles Active"
	echo "Example: export SPRING_PROFILES_ACTIVE=production"
	exit -1
elif [[ -z $SECRETS_VERSION ]]; then
	echo "Define Secrets Version"
	echo "Example: export SECRETS_VERSION=0.0.1"
	exit -1
fi

version=${SERVICE_VERSION}
secrets=${SECRETS_VERSION}

RESULT=$(docker service ls -f "name=${SERVICE_NAME}" --quiet | wc -l)

echo SERVICE_NAME=$SERVICE_NAME
echo SERVICE_VERSION=$SERVICE_VERSION
echo SECRETS_VERSION=$SECRETS_VERSION
echo MICROSIP_DOCKER_REGISTRY=$MICROSIP_DOCKER_REGISTRY
echo DOCKER_IMAGE_NAME=$DOCKER_IMAGE_NAME
echo DOCKER_EXPOSED_PORT=$DOCKER_EXPOSED_PORT
echo REPLICAS=$REPLICAS
echo DOCKER_NETWORKS=$DOCKER_NETWORKS
echo UPDATE_DELAY=$UPDATE_DELAY
echo UPDATE_PARALLELISM=$UPDATE_PARALLELISM
echo SPRING_PROFILES_ACTIVE=$SPRING_PROFILES_ACTIVE
echo version=$version
echo secrets=$secrets

MEM=300m
META=100m
DOCKER_MEM=450m

JAVA_OPTS="-server -d64 -Xmx$MEM -Xms$MEM \
-XX:MetaspaceSize=$META -XX:MaxMetaspaceSize=$META \
-XX:NewRatio=8 -XX:SurvivorRatio=6 -XX:+UseConcMarkSweepGC \
-XX:+CMSParallelRemarkEnabled -XX:+UseCMSInitiatingOccupancyOnly \
-XX:CMSInitiatingOccupancyFraction=70 \
-XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark \
-XX:+UnlockCommercialFeatures -XX:+FlightRecorder"

# @see https://github.com/moby/moby/issues/28956
if [[ $RESULT -gt 0 ]]; then
	echo "Service ${SERVICE_NAME} Found"
	echo "Updating Service ${SERVICE_NAME}"
	docker service update \
		--limit-memory ${DOCKER_MEM} \
		--replicas ${REPLICAS} \
		--secret-add source=spring.cloud.config.uri,target=spring.cloud.config.uri.${secrets}  \
		--secret-add source=spring.cloud.config.username,target=spring.cloud.config.username.${secrets}  \
		--secret-add source=spring.cloud.config.password,target=spring.cloud.config.password.${secrets}  \
		--secret-add source=spring.rabbitmq.username,target=spring.rabbitmq.username.${secrets}  \
		--secret-add source=spring.rabbitmq.password,target=spring.rabbitmq.password.${secrets}  \
		--env-add SPRING_CLOUD_CONFIG_URI_FILE="/run/secrets/spring.cloud.config.uri.${secrets}" \
		--env-add SPRING_CLOUD_CONFIG_USERNAME_FILE="/run/secrets/spring.cloud.config.username.${secrets}" \
		--env-add SPRING_CLOUD_CONFIG_PASSWORD_FILE="/run/secrets/spring.cloud.config.password.${secrets}" \
		--env-add SPRING_RABBITMQ_HOST=rabbitmq \
		--env-add SPRING_RABBITMQ_PORT=5672 \
		--env-add SPRING_RABBITMQ_USERNAME_FILE="/run/secrets/spring.rabbitmq.username.${secrets}" \
		--env-add SPRING_RABBITMQ_PASSWORD_FILE="/run/secrets/spring.rabbitmq.password.${secrets}" \
		--env-add SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE} \
		--env-add JAVA_OPTS="${JAVA_OPTS}" \
		--with-registry-auth \
		--update-delay="${UPDATE_DELAY}" \
		--update-parallelism=${UPDATE_PARALLELISM} \
		--image ${MICROSIP_DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${version} \
		--force \
		${SERVICE_NAME}
else
	echo "Service ${SERVICE_NAME} Not Found"
	echo "Creating Service ${SERVICE_NAME}"
	docker service create --name ${SERVICE_NAME} \
		--limit-memory ${DOCKER_MEM} \
		${DOCKER_NETWORKS} --replicas ${REPLICAS} \
		--secret source=spring.cloud.config.uri,target=spring.cloud.config.uri.${secrets}  \
		--secret source=spring.cloud.config.username,target=spring.cloud.config.username.${secrets}  \
		--secret source=spring.cloud.config.password,target=spring.cloud.config.password.${secrets}  \
		--secret source=spring.rabbitmq.username,target=spring.rabbitmq.username.${secrets}  \
		--secret source=spring.rabbitmq.password,target=spring.rabbitmq.password.${secrets}  \
		-e SPRING_CLOUD_CONFIG_URI_FILE="/run/secrets/spring.cloud.config.uri.${secrets}" \
		-e SPRING_CLOUD_CONFIG_USERNAME_FILE="/run/secrets/spring.cloud.config.username.${secrets}" \
		-e SPRING_CLOUD_CONFIG_PASSWORD_FILE="/run/secrets/spring.cloud.config.password.${secrets}" \
		-e SPRING_RABBITMQ_HOST=rabbitmq \
		-e SPRING_RABBITMQ_PORT=5672 \
		-e SPRING_RABBITMQ_USERNAME_FILE="/run/secrets/spring.rabbitmq.username.${secrets}" \
		-e SPRING_RABBITMQ_PASSWORD_FILE="/run/secrets/spring.rabbitmq.password.${secrets}" \
		-e SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE} \
		-e JAVA_OPTS="${JAVA_OPTS}" \
		--with-registry-auth \
		--update-delay="${UPDATE_DELAY}" \
		--update-parallelism=${UPDATE_PARALLELISM} \
		${MICROSIP_DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${version}
fi


