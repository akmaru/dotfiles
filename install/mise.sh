#!/bin/bash
# Install mise: https://mise.jdx.dev

set -euox pipefail

DOT_PATH=$(cd $(dirname $0)/../; pwd);

MISE_USER_DIR="${HOME}/.config/mise"
curl https://mise.run | sh

mkdir -p ${MISE_USER_DIR}
ln -sf "${DOT_PATH}"/mise/config.toml ${MISE_USER_DIR}/config.toml

mise install
mise doctor
