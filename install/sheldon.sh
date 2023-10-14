#!/bin/bash
set -euox pipefail

case $OSTYPE in
  linux*)
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
      | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    ;;
  darwin*)
    # sheldon will be installed by brew
    type "sheldon"
esac

mkdir -p $HOME/.config/sheldon
ln -sf ${DOT_PATH}/sheldon/plugins.toml $HOME/.config/sheldon/plugins.toml
