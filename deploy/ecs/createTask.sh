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
elif [[ -z $TASK_NAME ]]; then
	echo "Define Task Name"
	echo "Example: export TASK_NAME=ms-articulos-microservice-task"
	exit -1
elif [[ -z $TASK_CPU ]]; then
	echo "Define Task CPU"
	echo "Example: export TASK_CPU=512"
	exit -1
elif [[ -z $TASK_MEMORY ]]; then
	echo "Define Task Memory"
	echo "Example: export TASK_MEMORY=1024"
	exit -1
elif [[ -z $PREFIX_STREAM ]]; then
	echo "Define Prefix Stream"
	echo "Example: export PREFIX_STREAM=ecs"
	exit -1
elif [[ -z $SPRING_PROFILES_ACTIVE ]]; then
	echo "Define "
	echo "Example: export SPRING_PROFILES_ACTIVE=dev-ecs"
	exit -1
elif [[ -z $SPRING_CONFIG_IMPORT ]]; then
	echo "Define "
	echo "Example: export SPRING_CONFIG_IMPORT=configserver:http://admin:admin@ms-configuration-service.mpaas:8888"
	exit -1
elif [[ -z $SPRING_CLOUD_CONFIG_USERNAME ]]; then
	echo "Define "
	echo "Example: export SPRING_CLOUD_CONFIG_USERNAME=user"
	exit -1
elif [[ -z $SPRING_CLOUD_CONFIG_PASSWORD ]]; then
	echo "Define "
	echo "Example: export SPRING_CLOUD_CONFIG_PASSWORD=password"
	exit -1
elif [[ -z $SPRING_RABBITMQ_HOST ]]; then
	echo "Define "
	echo "Example: export SPRING_RABBITMQ_HOST=rabbitmq-service.mpaas"
	exit -1
elif [[ -z $SPRING_RABBITMQ_PORT ]]; then
	echo "Define "
	echo "Example: export SPRING_RABBITMQ_PORT=5672"
	exit -1
elif [[ -z $SPRING_RABBITMQ_USERNAME ]]; then
	echo "Define "
	echo "Example: export SPRING_RABBITMQ_USERNAME=user"
	exit -1
elif [[ -z $SPRING_RABBITMQ_PASSWORD ]]; then
	echo "Define "
	echo "Example: export SPRING_RABBITMQ_PASSWORD=password"
	exit -1
elif [[ -z $JAVA_MEM ]]; then
	echo "Define Java Memory"
	echo "Example: export JAVA_MEM=350m"
	exit -1
elif [[ -z $JAVA_META ]]; then
	echo "Define Java Meta"
	echo "Example: export JAVA_META=150m"
	exit -1
elif [[ -z $SERVICE_VERSION ]]; then
	echo "Define Service Version"
	echo "Example: export SERVICE_VERSION=1.0.0"
	exit -1
elif [[ -z $AWS_DEFAULT_REGION ]]; then
	echo "AWS Default Region"
	echo "Example: export AWS_DEFAULT_REGION=us-east-1"
	exit -1
fi

JAVA_OPTS="-server -d64 -Xmx$JAVA_MEM -Xms$JAVA_MEM \
-XX:MetaspaceSize=$JAVA_META -XX:MaxMetaspaceSize=$JAVA_META \
-XX:NewRatio=8 -XX:SurvivorRatio=6 -XX:+UseConcMarkSweepGC \
-XX:+CMSParallelRemarkEnabled -XX:+UseCMSInitiatingOccupancyOnly \
-XX:CMSInitiatingOccupancyFraction=70 \
-XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark \
-XX:+UnlockCommercialFeatures -XX:+FlightRecorder"
echo "JavaOpts $JAVA_OPTS"
export JAVA_OPTS=$JAVA_OPTS

# -- Task definition --
envsubst < /deploy/deploy/ecs/initial-task-template.json > /deploy/deploy/ecs/initial-task.json
cat /deploy/deploy/ecs/initial-task.json

echo "Task name $TASK_NAME"

RESULT=$(aws ecs list-task-definitions --sort DESC --family-prefix ${TASK_NAME} | jq '.taskDefinitionArns[0] | length')

if [[ $RESULT -gt 0 ]]; then
	echo "Task ${TASK_NAME} Found"
	echo "Updating Task ${TASK_NAME}"
	aws ecs register-task-definition --cli-input-json file:///deploy/deploy/ecs/initial-task.json
else
	echo "Task ${TASK_NAME} Not Found"
	echo "Creating Task ${TASK_NAME}"
	aws ecs register-task-definition --cli-input-json file:///deploy/deploy/ecs/initial-task.json
fi