#!/bin/bash
set -euo pipefail

# AWS-related installs.
#
# session-manager-plugin: install into a user-local bin WITHOUT sudo. AWS only
# distributes signed .pkg (macOS) / .deb (Ubuntu) which normally need root, so we
# extract the binary from the package payload and drop it on PATH.
#
# Env overrides:
#   SMP_INSTALL_DIR  install destination (default: ~/.local/bin)
#   SMP_FORCE        set to reinstall even if already present

BASE_URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest"
INSTALL_DIR="${SMP_INSTALL_DIR:-$HOME/.local/bin}"
BIN="session-manager-plugin"

if command -v "$BIN" >/dev/null 2>&1 && [ -z "${SMP_FORCE:-}" ]; then
  echo "session-manager-plugin already installed: $(command -v "$BIN") ($("$BIN" --version))"
  exit 0
fi

os="$(uname -s)"
arch="$(uname -m)"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

case "$os" in
Darwin)
  case "$arch" in
  arm64) url="$BASE_URL/mac_arm64/session-manager-plugin.pkg" ;;
  x86_64) url="$BASE_URL/mac/session-manager-plugin.pkg" ;;
  *)
    echo "unsupported macOS arch: $arch" >&2
    exit 1
    ;;
  esac
  echo "Downloading $url"
  curl -fsSL -o "$tmp/smp.pkg" "$url"
  pkgutil --expand "$tmp/smp.pkg" "$tmp/expanded"
  payload="$(find "$tmp/expanded" -name Payload | head -1)"
  mkdir -p "$tmp/payload"
  # The pkg Payload is a (possibly gzipped) cpio archive; bsdtar handles both.
  (cd "$tmp/payload" && tar xf "$payload")
  src="$(find "$tmp/payload" -name "$BIN" -type f | head -1)"
  ;;
Linux)
  case "$arch" in
  x86_64 | amd64) url="$BASE_URL/ubuntu_64bit/session-manager-plugin.deb" ;;
  aarch64 | arm64) url="$BASE_URL/ubuntu_arm64/session-manager-plugin.deb" ;;
  *)
    echo "unsupported Linux arch: $arch" >&2
    exit 1
    ;;
  esac
  echo "Downloading $url"
  curl -fsSL -o "$tmp/smp.deb" "$url"
  if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb -x "$tmp/smp.deb" "$tmp/extract"
  else
    # Fallback without dpkg: unpack the .deb (ar) and its data archive.
    (cd "$tmp" && ar x smp.deb && mkdir -p extract && tar -xf data.tar.* -C extract)
  fi
  src="$(find "$tmp/extract" -name "$BIN" -type f | head -1)"
  ;;
*)
  echo "unsupported OS: $os" >&2
  exit 1
  ;;
esac

if [ -z "${src:-}" ] || [ ! -f "$src" ]; then
  echo "failed to locate $BIN in package payload" >&2
  exit 1
fi

mkdir -p "$INSTALL_DIR"
install -m 0755 "$src" "$INSTALL_DIR/$BIN"
# curl-downloaded files may carry a quarantine attr on macOS; drop it if present.
if [ "$os" = Darwin ]; then
  xattr -d com.apple.quarantine "$INSTALL_DIR/$BIN" 2>/dev/null || true
fi

echo "Installed: $INSTALL_DIR/$BIN ($("$INSTALL_DIR/$BIN" --version))"
case ":$PATH:" in
*":$INSTALL_DIR:"*) ;;
*) echo "NOTE: $INSTALL_DIR is not on PATH. Add it to use $BIN." ;;
esac
