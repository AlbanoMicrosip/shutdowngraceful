#!/usr/bin/env bash
#+--------------------------------------------------------------------------------+
#|                                                                                |
#|          @author Juan Francisco Alvarez Urquijo <paco@technogi.com.mx>         |
#|                                                                                |
#|                                                                                |
#+--------------------------------------------------------------------------------+
# runremote.sh (revised, not dependent upon /dev/stdin)
# usage: runremote.sh docker.login.sh localscript remoteuser remotehost ssh-key.pem arg1 arg2 ...
# @see http://backreference.org/2011/08/10/running-local-script-remotely-with-arguments/
# @see https://zaiste.net/posts/a_few_ways_to_execute_commands_remotely_using_ssh/

realscript=$1
dockerlogin=$2
user=$3
host=$4
key=$5
shift 5

echo "Script to run is $realscript in $PWD"
echo "Script content is "
cat "$realscript"
echo "Connecting to $host with user $user and key $key"

# escape the arguments
declare -a args

count=0
for arg in "$@"; do
  args[count]=$(printf '%q' "$arg")
  # Replace Double and Single Quotes
  args[count]="${args[count]//\\\"/\"}"
  args[count]="${args[count]//\\\'/\"}"
  count=$((count+1))
done

printf 'args is %s\n' "${args[*]}"

{
  printf '%s\n' "${args[*]}"
  cat "$dockerlogin"
  cat "$realscript"
} | ssh -i $key $user@$host "bash -s"
