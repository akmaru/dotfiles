#!/bin/bash
set -euox pipefail

curl https://rtx.pub/install.sh | sh
ln -sf "${DOT_PATH}"/.tool-versions ~/.tool-versions
