#!/usr/bin/env bash

set -e

if [[ "${CI_BUILD_APPROVED}" == "true" ]]; then
    echo "Manual build won't execute test"
else
    echo "Home is $HOME" && echo `whoami`
    ls -la $HOME/.embedmongo/
    echo "Executing tests..."
    ./gradlew test -Dspring.profiles.active=local -DPROFILE=local
fi
