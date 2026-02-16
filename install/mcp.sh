#!/bin/bash

set -euox pipefail

DOT_PATH=$(cd $(dirname $0)/../; pwd);

mkdir -p ${XDG_CONFIG_HOME}/mcp/master-mcp.d

ln -sf ${DOT_PATH}/mcp/master-mcp.json ${XDG_CONFIG_HOME}/mcp/master-mcp.json
ln -sf ${DOT_PATH}/mcp/sync-mcp.sh ${XDG_BIN_HOME}/sync-mcp.sh
$XDG_BIN_HOME/sync-mcp.sh
