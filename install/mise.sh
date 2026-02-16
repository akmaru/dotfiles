#!/bin/bash
# Install mise: https://mise.jdx.dev

set -euox pipefail

# Set DOT_PATH if not already set (when sourced from install_minimum.sh, it should be already set)
if [[ -z "${DOT_PATH:-}" ]]; then
    DOT_PATH=$(cd $(dirname "${BASH_SOURCE[0]}")/../; pwd)
fi

MISE_USER_DIR="${HOME}/.config/mise"
curl https://mise.run | sh

mkdir -p ${MISE_USER_DIR}
ln -sf "${DOT_PATH}"/mise/config.toml ${MISE_USER_DIR}/config.toml

echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc

# Add mise to PATH before running mise commands
export PATH="${HOME}/.local/share/mise/shims:${HOME}/.local/bin:${PATH}"

mise install
mise doctor || true
