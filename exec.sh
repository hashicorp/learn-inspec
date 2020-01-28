#!/bin/bash -x

make

function inspec() {
  docker run \
    -v "${LEARN_DIR:?"Pass with -d"}":/learn \
    -v /tmp:/tmp \
    -v /var/run/docker.sock:/var/run/docker.sock \
    inspec \
    "$@"
}


function help() {
  echo <<HELP
  Usage: $0 -f ~/learn/pages
HELP
}


while getopts "d:h" opt; do
  case ${opt} in
    h ) # process option a
      ;;
    d ) LEARN_DIR="$OPTARG"
      ;;
  esac
done


HTML_REPORT="/tmp/inspec-$RANDOM$$.html"
inspec check profiles/terraform &&
  inspec exec profiles/terraform \
      --target=docker://hashi_inspec \
      --reporter cli html:"${HTML_REPORT:?}" \
      --log-level=debug
[ -f "$HTML_REPORT" ] && open "$HTML_REPORT"
