#!/bin/bash
set -euo pipefail

if [ ! -f .env ]; then
    cat <<EOT > .env
HOST_USERNAME=`whoami`
HOST_UID=`id -u`
HOST_GID=`id -g`
EOT
fi
