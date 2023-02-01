#!/bin/bash -x
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


trap cleanup EXIT
trap cleanup TERM
trap cleanup ERR

# Run our ruby environment in docker for portablity
function inspec() {
  docker run \
    -e MARKDOWN=/markdown \
    -v "${LEARN_DIR:?"Pass with -d"}":/markdown \
    -v /tmp:/tmp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    inspec \
    "$@"
}

# Parse our options
function help() {
  echo <<HELP
  Usage: $0 -d ~/learn/pages -p terraform
HELP
}

# Cleanup function TRAP'ed
function cleanup(){
    command docker kill inspec-target
}

# Multi os browser integration
function open () {
  case "$OSTYPE" in
     cygwin*)
        command "cmd" /c start $@
        ;;
     linux*)
        command "xdg-open" $@ &
        ;;
     darwin*)
        command "open" $@
        ;;
  esac
}


while getopts "d:p:h" opt; do
  case ${opt} in
    h ) # process option a
      ;;
    d ) LEARN_DIR="$OPTARG"
      ;;
    p ) PROFILE="$OPTARG"
      ;;
  esac
done


# Allow us to call script from any pwd
SCRIPT_DIR="${0%/*}"

cd "$SCRIPT_DIR"

# Build our inspec container
make

# Run the target container
declare -xi TARGET_RUNNING=$(docker ps | grep -c inspec-target)

if [[ ${TARGET_RUNNING} == 0 ]] ; then
   ./target/background.sh
fi

# Run inspec
HTML_REPORT="/tmp/inspec-$RANDOM$$.html"

# You can put "command" in front of this to run outside of docker
inspec check "profiles/${PROFILE:?"Pass with -p"}" &&
  inspec exec "profiles/${PROFILE}" \
      --target=docker://inspec-target \
      --reporter cli html:"${HTML_REPORT:?}" \
      --log-level=debug \
      --show-progress


[ -f "$HTML_REPORT" ] && open "$HTML_REPORT"

cleanup
