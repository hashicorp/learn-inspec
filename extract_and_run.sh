#!/bin/bash -x

# Run our ruby environment in docker for portablity
function inspec() {
  docker run \
    -v "${LEARN_DIR:?"Pass with -d"}":/learn \
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

HTML_REPORT="/tmp/inspec-$RANDOM$$.html"

# Allow us to call script from any pwd
SCRIPT_DIR="${0%/*}"

cd "$SCRIPT_DIR"

# Build our inspec container
make

# Run inspec
# You can put "command" in front of this to run outside of docker
inspec check "profiles/${PROFILE:?"Pass with -p"}" &&
  inspec exec "profiles/${PROFILE}" \
      --target=docker://inspec-target \
      --reporter cli html:"${HTML_REPORT:?}" \
      --log-level=debug \
      --show-progress

[ -f "$HTML_REPORT" ] && open "$HTML_REPORT"

