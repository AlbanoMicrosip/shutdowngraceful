#!/usr/bin/env bash
#+--------------------------------------------------------------------------------+
#|                                                                                |
#|          @author Juan Francisco Alvarez Urquijo <paco@technogi.com.mx>         |
#|                                                                                |
#|                                                                                |
#+--------------------------------------------------------------------------------+

echo "Installing envsubst..."
export BUILD_DEPS="gettext"
export RUNTIME_DEPS="libintl"

set -x && \
  apk add --update $RUNTIME_DEPS && \
  apk add --virtual build_deps $BUILD_DEPS &&  \
  cp /usr/bin/envsubst /usr/local/bin/envsubst && \
  apk del build_deps

