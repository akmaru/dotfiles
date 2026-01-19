#!/bin/bash
set -euox pipefail

case $OSTYPE in
  linux*)
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
      | bash -s -- --repo rossmacarthur/sheldon --to "${XDG_BIN_HOME}" -f
    ;;
  darwin*)
    # sheldon will be installed by brew
    type "sheldon"
esac

mkdir -p "${XDG_CONFIG_HOME}"/sheldon
ln -sf "${DOT_PATH}"/sheldon/plugins.toml "${XDG_CONFIG_HOME}"/sheldon/plugins.toml
