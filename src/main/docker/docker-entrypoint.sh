#!/usr/bin/env bash
# @see http://blog.kablamo.org/2015/11/08/bash-tricks-eux/
set -euo pipefail

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
# http://ahmed.amayem.com/bash-indirect-expansion-exploration/
file_env() {
	echo "$1"
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
  # Only verify and export the Environment Variables that User Needs to Expose
	if [ -n "${val}" ]; then
	  echo "Exporting environment variables: $var=$val"
		export "$var"="$val"
	fi
	unset "$fileVar"
}

envs=(
	SPRING_CLOUD_CONFIG_URI
	SPRING_CLOUD_CONFIG_USERNAME
	SPRING_CLOUD_CONFIG_PASSWORD
	SPRING_RABBITMQ_USERNAME
	SPRING_RABBITMQ_PASSWORD
)

for e in "${envs[@]}"; do
	file_env "$e"
done

#rm -rf /var/run/rsyslogd.pid
#service rsyslog start

exec java -jar /app.jar