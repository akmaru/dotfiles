#!/bin/bash
set -euxo pipefail

./install/minimum.sh

export DOT_PATH=$(dirname "$(readlink -f "$0")")

case $OSTYPE in
  linux*)
    ${DOT_PATH}/install/ubuntu.sh
    ;;
  darwin*)
    # TODO: separase install_mac.sh
    ;;
  *)
    echo "$0 not support to install in ${OSTYPE}"
    exit 1
    ;;
esac

#
# rtx
#
if [ -z "${REMOTE_CONTAINER:-}" ]; then
  "${DOT_PATH}"/install/rtx.sh
fi

#
# Rust
#
#./install_rust.sh
