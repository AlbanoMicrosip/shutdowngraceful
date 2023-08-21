#!/usr/bin/env bash
#+--------------------------------------------------------------------------------+
#|                                                                                |
#|          @author Juan Francisco Alvarez Urquijo <paco@technogi.com.mx>         |
#|                                                                                |
#|                                                                                |
#+--------------------------------------------------------------------------------+

set -e

DOCKER_LOGIN_COMMAND="aws ecr get-login --region us-east-1"

echo "Login to Microsip Docker Image Registry"

LOGIN_SUCCESS="Login Succeeded"

RESULT=$(eval $(${DOCKER_LOGIN_COMMAND}) | grep "${LOGIN_SUCCESS}")

if [[ $RESULT == $LOGIN_SUCCESS ]]; then
	echo "Login Succeeded to Microsip Docker Image Registry"
else
	echo "Access Denied to Microsip Docker Image Registry"
	return -1
fi
