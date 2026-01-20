#!/bin/bash
# Install Claude Code

set -euox pipefail

DOT_PATH=$(cd $(dirname $0)/../; pwd);

curl -fsSL https://claude.ai/install.sh | bash

