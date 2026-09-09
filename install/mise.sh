#!/bin/bash
# Install mise: https://mise.jdx.dev

set -euox pipefail

# Set DOT_PATH if not already set (when sourced from install_minimum.sh, it should be already set)
if [[ -z "${DOT_PATH:-}" ]]; then
    DOT_PATH=$(cd $(dirname "${BASH_SOURCE[0]}")/../; pwd)
fi

MISE_USER_DIR="${HOME}/.config/mise"
# Pin mise: 2026.6.x regressed pipx installs by injecting an --uploaded-prior-to
# pip arg that uv (pipx's backend) rejects ("unexpected argument"), which breaks
# `mise install` for ansible and aborts install_minimum.sh. Pin to the last known
# good release until the upstream regression is fixed. Override via MISE_VERSION.
export MISE_VERSION="${MISE_VERSION:-v2026.2.23}"
curl https://mise.run | sh

mkdir -p ${MISE_USER_DIR}
ln -sf "${DOT_PATH}"/mise/config.toml ${MISE_USER_DIR}/config.toml

echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc

# Add mise to PATH before running mise commands
export PATH="${HOME}/.local/share/mise/shims:${HOME}/.local/bin:${PATH}"

# This file is the *user* config (linked above), but "mise/config.toml" is also
# one of the project config paths mise auto-discovers relative to the cwd. So
# every mise command run from inside this repo finds it as an untrusted project
# config and refuses to resolve tools -- shims then exit non-zero with no output,
# which breaks anything launched from here (e.g. nvim via ~/.local/bin).
# Trusting it is safe: it is our own config, already active as the user config.
mise trust "${DOT_PATH}/mise/config.toml"

mise install
mise doctor || true
