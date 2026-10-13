#!/bin/bash
set -e -o pipefail

echo "=== diy-script: 开始自定义编译配置 ==="

# 修改默认IP
echo "[diy] 修改默认IP为 192.168.2.1"
sed -i 's/192.168.6.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i -E 's|^root:[^:]*:|root::|' package/base-files/files/etc/shadow

# 移除要替换的包（来自官方 feeds）
echo "[diy] 移除 feeds 中的旧版app"
# rm -rf feeds/packages/net/mosdns feeds/packages/net/msd_lite feeds/packages/net/smartdns feeds/packages/net/dae feeds/packages/net/daed package/feeds/luci/luci-app-dae package/feeds/luci/luci-app-daed
# 下方第一条：来自上方的修改，移除了“dae、luci-app-dae”、“daed、luci-app-daed”、mosdns、smartdns 4个插件，并注释掉下方4条 clone_if_missing 对应命令
# 下方第一条：若要使用“dae、luci-app-dae”和“daed、luci-app-daed”2个插件必须保留，还必须保留下方 clone_if_missing 相关拉取命令，重新拉取第三方 luci-app-daed（是 dae + daed + luci-app 二合一），再修改它的 Makefile 文件指向 golang1.27，它们关联 golang1.27 升级
# 若想使用源码自带 msd_lite ，只需删除 feeds/packages/net/msd_lite，并注释掉下方2条相关的clone_if_missing.....msd_lite 和 clone_if_missing.....luci-app-msd_lite 即可
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/luci-app-passwall

# 克隆第三方插件源（如果目录已存在则跳过，避免重复执行报错）
clone_if_missing() {
  local repo="$1" branch="$2" dest="$3"
  if [ -d "$dest" ]; then
    echo "[diy] 跳过已存在的仓库: $dest"
  else
    echo "[diy] 克隆: $repo -> $dest"
    git clone --depth=1 ${branch:+-b "$branch"} "$repo" "$dest"
  fi
}

#clone_if_missing https://github.com/sbwml/luci-app-mosdns              ""     package/luci-app-mosdns
clone_if_missing https://github.com/ximiTech/luci-app-msd_lite         ""     package/luci-app-msd_lite
clone_if_missing https://github.com/ximiTech/msd_lite                  ""     package/msd_lite
#clone_if_missing https://github.com/pymumu/luci-app-smartdns           ""     package/luci-app-smartdns
#clone_if_missing https://github.com/pymumu/openwrt-smartdns            ""     package/smartdns
#clone_if_missing https://github.com/QiuSimons/luci-app-daed            ""     package/dae
clone_if_missing https://github.com/Openwrt-Passwall/openwrt-passwall-packages "" package/passwall-packages
clone_if_missing https://github.com/Openwrt-Passwall/openwrt-passwall  ""     package/passwall-luci
#clone_if_missing https://github.com/EasyTier/luci-app-easytier.git     ""     package/luci-app-easytier

# 若要使用“luci-app-daed”插件，去掉下方的注释命令（命令的作用：修改 package/dae/daed/Makefile 文件，添加一条命令：GO_PKG_INSTALL_EXTRA:=webrender/web，告诉 OpenWrt 的 Golang 编译工具链，在编译 daed 时，除了编译 Go 代码，还要把 Web 前端静态网页资源（UI 界面 webrender/web）一并打包进去
# 还要恢复上方的 “rm -rf feeds/packages/net/dae feeds/packages/net/daed package/feeds/luci/luci-app-dae package/feeds/luci/luci-app-daed” 删除源码自带的命令
# 还必须恢复上方 clone_if_missing.....luci-app-daed 拉取命令，重新拉取第三方 luci-app-daed（二合一）
#sed -i '/^GO_PKG:=github.com\/daeuniverse\/dae-wing$/a GO_PKG_INSTALL_EXTRA:=webrender/web' \
#  package/dae/daed/Makefile

# 修改版本为编译日期
DATE_VERSION="$(date +%Y.%m.%d)"
VERSION_FILE="include/version.mk"
echo "[diy] 修改版本为编译日期: $DATE_VERSION"
sed -i "s/^VERSION_NUMBER:=.*/VERSION_NUMBER:=-$DATE_VERSION by WoChen5770/" "$VERSION_FILE"

echo "=== diy-script: 完成 ==="
