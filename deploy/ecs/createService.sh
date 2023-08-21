#!/usr/bin/env bash
#+--------------------------------------------------------------------------------+
#|                                                                                |
#|          @author Juan Francisco Alvarez Urquijo <paco@technogi.com.mx>         |
#|                                                                                |
#|                                                                                |
#+--------------------------------------------------------------------------------+

set -e

if [[ -z $FARGATE_VERSION ]]; then
	echo "Define Task Name"
	echo "Example: export FARGATE_VERSION=1.1.0"
	exit -1
elif [[ -z $AWS_SUBNETS ]]; then
	echo "Define AWS Subnets"
	echo "Example: export AWS_SUBNETS=\"subnet-d5ce1ab2\""
	exit -1
elif [[ -z $AWS_SECURITY_GROUPS ]]; then
	echo "Define AWS Security Groups"
	echo "Example: export AWS_SECURITY_GROUPS=\"sg-80456cc8\""
	exit -1
elif [[ -z $TASK_NAME ]]; then
	echo "Define Task Name"
	echo "Example: export TASK_NAME=ms-articulos-microservice-task"
	exit -1
elif [[ -z $CLUSTER_NAME ]]; then
	echo "Define Cluster Name"
	echo "Example: export CLUSTER_NAME=mpaas-cluster"
	exit -1
elif [[ -z $SERVICE_NAME ]]; then
	echo "Define Service Name"
	echo "Example: export SERVICE_NAME=ms-articulos-microservice"
	exit -1
elif [[ -z $PREFIX_STREAM ]]; then
	echo "Define Prefix Stream"
	echo "Example: export PREFIX_STREAM=ecs"
	exit -1
elif [[ -z $ROUTING_POLICY ]]; then
	echo "Define Routing Policy"
	echo "Example: export ROUTING_POLICY=MULTIVALUE"
	exit -1
fi

TASK_REVISION=$(aws ecs list-task-definitions --family-prefix ${TASK_NAME} --sort DESC | jq -r '.taskDefinitionArns[0]' | awk -F':' '{print $7}')
export TASK_REVISION=$TASK_REVISION
echo "TASK_REVISION is ${TASK_REVISION}"

# -- Log Group --
RESULT=$(aws logs describe-log-groups --log-group-name-prefix /${PREFIX_STREAM}/${SERVICE_NAME} | jq '.logGroups[] | length')
if ! [[ $RESULT -gt 0 ]]; then
	echo "Log Group /${PREFIX_STREAM}/${SERVICE_NAME} Not Found"
	echo "Creating Log Group /${PREFIX_STREAM}/${SERVICE_NAME}"
  aws logs create-log-group --log-group-name /${PREFIX_STREAM}/${SERVICE_NAME}
else
	echo "Log Group /${PREFIX_STREAM}/${SERVICE_NAME} Found"
fi

RESULT=$(aws ecs list-services --cluster $CLUSTER_NAME | jq '.serviceArns[] | select(. | contains("/" + env.SERVICE_NAME)) | length')

if [[ $RESULT -gt 0 ]]; then
	echo "Service ${SERVICE_NAME} Found"
	echo "Updating Service ${SERVICE_NAME}"
	aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${TASK_NAME} --force-new-deployment
else
	echo "Service ${SERVICE_NAME} Not Found"
	echo "Creating Service ${SERVICE_NAME}"
	# -- Service discovery --
  RESULT=$(aws servicediscovery list-services --filters Name=NAMESPACE_ID,Values=${NS_ID},Condition=EQ | jq '.Services[] | .Name | select(. | contains(env.SERVICE_NAME)) | length')

	if [[ $RESULT -gt 0 ]]; then
		echo "Service Discovery for ${SERVICE_NAME} Found"
		SERVICE_ARN=$(aws servicediscovery list-services --filters Name=NAMESPACE_ID,Values=${NS_ID},Condition=EQ | jq '.Services[] | select(.Name | contains(env.SERVICE_NAME)) | .Arn')
	else
		echo "Service Discovery for ${SERVICE_NAME} Not Found"
		echo "Creating Service Discovery for ${SERVICE_NAME}"
		envsubst < /deploy/deploy/ecs/service-discovery-template.json > /deploy/deploy/ecs/service-discovery.json
		cat /deploy/deploy/ecs/service-discovery.json
		SERVICE_ARN=$(aws servicediscovery create-service --cli-input-json file:///deploy/deploy/ecs/service-discovery.json | jq '.Service.Arn')
	fi

	echo "Service Discovery ARN: ${SERVICE_ARN}"
  export SERVICE_ARN=$SERVICE_ARN

	# -- ECS Service --
	envsubst < /deploy/deploy/ecs/initial-service-template.json > /deploy/deploy/ecs/initial-service.json
	cat /deploy/deploy/ecs/initial-service.json
	aws ecs create-service --cli-input-json file:///deploy/deploy/ecs/initial-service.json --service-registries registryArn=${SERVICE_ARN}
fi
