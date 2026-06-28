#!/bin/bash
set -euox pipefail

# Set DOT_PATH if not already set (exported by install_minimum.sh when sourced)
DOT_PATH="${DOT_PATH:-$(cd "$(dirname "$0")/.."; pwd)}"

ln -sf "${DOT_PATH}/.gitconfig_linux" ~/.gitconfig_os

packages=("
  ca-certificates \
  curl \
  gcc \
  git \
  libsecret-1-0 \
  libsecret-1-dev \
  make \
  neovim \
  pkg-config \
  tmux \
  zsh \
")

. /etc/os-release

case $VERSION_CODENAME in
  jammy | noble)
    ;;
  *)
    echo "$0 not support to install in ${VERSION_CODENAME}"
    exit 1
    ;;
esac

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update \
  && sudo -E apt-get install -y --no-install-recommends $packages \
  && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*
 
# Build the libsecret git credential helper. Ubuntu's git package no longer
# ships the contrib source under /usr/share/doc, so fetch the single source file
# for the installed git version from upstream and compile it onto PATH.
# Non-fatal: a network/build hiccup must not abort the whole install.
install_git_credential_libsecret() {
  local gv src
  gv=$(git --version | awk '{print $3}')
  src=$(mktemp -d)
  if curl -fsSL "https://raw.githubusercontent.com/git/git/v${gv}/contrib/credential/libsecret/git-credential-libsecret.c" \
       -o "${src}/git-credential-libsecret.c" \
     && gcc -o "${src}/git-credential-libsecret" "${src}/git-credential-libsecret.c" \
       $(pkg-config --cflags --libs libsecret-1 glib-2.0); then
    sudo install -m755 "${src}/git-credential-libsecret" /usr/local/bin/git-credential-libsecret
  else
    echo "warning: failed to build git-credential-libsecret" >&2
  fi
  rm -rf "${src}"
}
install_git_credential_libsecret
