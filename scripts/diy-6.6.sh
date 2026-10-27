#!/bin/bash
set -e -o pipefail

WORKSPACE_ROOT="${GITHUB_WORKSPACE:-$(pwd)}"
GOLANG126_SRC_DIR="$WORKSPACE_ROOT/golang_update"
GOLANG126_FEED_DIR="feeds/packages/lang/golang1.27"
rm -rf "$GOLANG126_FEED_DIR"
mkdir -p "$GOLANG126_FEED_DIR"
cp -rf "$GOLANG126_SRC_DIR/." "$GOLANG126_FEED_DIR/"
./scripts/feeds update -f packages
./scripts/feeds install golang1.27

# passwall 和 daed 使用 golang1.27/host（修改拉取第三方 package/dae 和 package/passwall-packages 目录下所有 Makefile 文件，指向 golang1.27）
# 下方第一条命令与上方被注释掉的命令，中间少了一个“package/dae”，如要使用 luci-app-daed，请使用上方命令，还需要修改“diy-script.sh”脚本
#find package/dae package/passwall-packages -name "Makefile" -type f -exec sed -i \
find package/passwall-packages -name "Makefile" -type f -exec sed -i \
  -e 's|\<golang/golang-package.mk\>|golang1.27/golang-package.mk|g' \
  -e 's|\<golang/host\>|golang1.27/host|g' {} +
