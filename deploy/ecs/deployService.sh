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
elif [[ -z $NAME_SPACE ]]; then
	echo "Define Namespace"
	echo "Example: export NAME_SPACE=mpaas"
	exit -1
fi

echo "Task name $TASK_NAME"
echo "Cluster name $CLUSTER_NAME"
echo "Service name $SERVICE_NAME"
echo "Routing Policy $ROUTING_POLICY"
echo "Namespace $NAME_SPACE"
export NAME_SPACE=$NAME_SPACE

NS_ID=$(aws servicediscovery list-namespaces | jq -r '.Namespaces[] | select(.Name == env.NAME_SPACE) | .Id')
echo "Name Space ID $NS_ID"
export NS_ID=$NS_ID

/deploy/deploy/ecs/install_envsubst.sh
/deploy/deploy/ecs/createService.sh