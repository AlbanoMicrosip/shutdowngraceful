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
	echo "Example: export SERVICE_NAME=ms--microservice"
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
fi

SERVICE_VERSION=git_$CI_COMMIT_ID
export SERVICE_VERSION=$SERVICE_VERSION
echo "Service Version $SERVICE_VERSION"

AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
echo "AWS Default Region $SERVICE_VERSION"

/deploy/deploy/ecs/install_envsubst.sh
/deploy/deploy/ecs/createTask.sh