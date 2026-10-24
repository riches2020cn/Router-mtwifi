#!/bin/bash
#=================================================
# Copyright (c) 2019-2023 sky2016cn
# Author: sky2016cn
# licensed under the MIT License
# See /LICENSE for more information
# Description: Build OpenWrt using GitHub Actions
#=================================================
#1. Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' /builder/openwrt/package/base-files/files/bin/config_generate

#2. ImmortalWrt 更改主机名 Redmi-AX6000
sed -i 's/ImmortalWrt/Redmi-AX6000/g' /builder/openwrt/package/base-files/files/bin/config_generate

#3. Clear the login password
#sed -i -E 's|^root:[^:]*:|root::|' /builder/openwrt/package/base-files/files/etc/shadow

#4. 修改默认皮肤
#sed -i 's/+luci-theme-bootstrap/+luci-theme-argon/g' /builder/openwrt/feeds/luci/collections/luci/Makefile

#5. Replace with JerryKuKu’s Argon
#rm /builder/openwrt/package/lean/luci-theme-argon -rf
