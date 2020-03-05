#!/bin/bash

trap "exit 130" SIGINT
trap "exit 137" SIGKILL
trap "exit 143" SIGTERM

set -o errexit
set -o nounset
set -o pipefail

UHP_JSON='/etc/uhp/uhp.json'

main () {
    DEBUG=${DEBUG:-false}
    if [[ ${DEBUG} == "true" ]]
    then
      set -o xtrace
    fi

    if [[ -z ${DEPLOY_KEY} ]]
    then
      echo "[CRIT] - No deploy key found"
      exit 1
    fi

    # Register this host with CHN if needed
    chn-register.py \
        -p uhp \
        -d "${DEPLOY_KEY}" \
        -u "${CHN_SERVER}" -k \
        -o "${UHP_JSON}" \
        -i "${IP_ADDRESS}"

    local uid="$(cat ${UHP_JSON} | jq -r .identifier)"
    local secret="$(cat ${UHP_JSON} | jq -r .secret)"

    # Keep old var names, but create also create some new ones that
    # containedenv can understand
    export UHP_hpfeeds__debug="${DEBUG}"
    export UHP_hpfeeds__host="${FEEDS_SERVER}"
    export UHP_hpfeeds__port="${FEEDS_SERVER_PORT:-10000}"
    export UHP_hpfeeds__ident="${uid}"
    export UHP_hpfeeds__secret="${secret}"

    # Write out custom uhp config
    containedenv-config-writer.py \
      -p UHP_ \
      -f ini \
      -r /code/logging.cfg.template \
      -o /opt/uhp/logging.cfg

    cp -f /code/configs/*.json /opt/uhp/configs
    python3 /code/tagging.py --directory /opt/uhp/configs/ --tags "${TAGS}"
    /opt/uhp/uhp.py --log-sessions -H /opt/uhp/logging.cfg /opt/uhp/configs/${UHP_CONFIG} ${UHP_LISTEN_PORT}
}

main "$@"
