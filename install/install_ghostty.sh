#!/bin/bash
# Install Ghostty and place its config: https://ghostty.org
#
# Windows is not handled because Ghostty ships no Windows build.
set -euox pipefail

DOT_PATH="${DOT_PATH:-$(cd "$(dirname "$0")/.."; pwd)}"

case $OSTYPE in
  darwin*)
    # Installed by `brew bundle` (cask "ghostty" in Brewfile)
    ;;
  linux*)
    if ! command -v ghostty > /dev/null; then
      . /etc/os-release
      # The official Ubuntu repository carries Ghostty from 26.04 on. Older
      # releases only have community builds; the snap is chosen over the
      # curl-piped .deb installer to avoid running a third-party script.
      if dpkg --compare-versions "${VERSION_ID}" ge 26.04; then
        sudo apt-get update
        sudo apt-get install -y ghostty
      else
        sudo snap install ghostty --classic
      fi
    fi
    ;;
  *)
    echo "$0 not support to install in ${OSTYPE}"
    exit 1
    ;;
esac

# The XDG path is read on both macOS and Linux. Link the whole directory so
# files added to ghostty/ later are picked up without re-running this script.
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
ln -sfn "${DOT_PATH}/ghostty" "${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
