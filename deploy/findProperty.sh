#!/usr/bin/env bash
#+--------------------------------------------------------------------------------+
#|                                                                                |
#|          @author Juan Francisco Alvarez Urquijo <paco@technogi.com.mx>         |
#|                                                                                |
#|   eg. ./findProperty.sh my.property file.properties                            |
#|   eg. cat file.properties | ./findProperty.sh my.property                      |
#+--------------------------------------------------------------------------------+

set -e

target=$1

findStr()
{
    local target=$1
    local file=$2
    #echo target : $target
    #echo file : $file
    sed '/^\#/d' ${file} | grep ${target} | sed -e 's/ //g' |
        while read LINE
        do
            local KEY=$(echo $LINE | cut -d "=" -f 1)
            local VALUE=$(echo $LINE | cut -d "=" -f 2)
            [ ${KEY} == ${target} ] && {
                local UNKNOWN_NAME=$(echo $VALUE | grep '\${.*}' -o | sed 's/\${//' | sed 's/}//')
                if [ $UNKNOWN_NAME ];then
                    local UNKNOWN_VALUE=$(findStr ${UNKNOWN_NAME} ${file})
                    echo ${VALUE} | sed s/\$\{${UNKNOWN_NAME}\}/${UNKNOWN_VALUE}/
                else
                    echo $VALUE
                fi
                return
            }
        done
    return
}

if [ $2 ];then
    findStr ${target} $2
else
    while read data; do
        echo ${data} >> .__tmpfile_
    done
    findStr ${target} .__tmpfile_
    rm -f .__tmpfile_
fi