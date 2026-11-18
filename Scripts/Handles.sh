#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

FEEDS_PATH="./feeds"
PACKAGE_PATH="./package"

#修补命令统一入口：FIX <名称> <守卫目录> <命令...>
#守卫目录不存在时直接跳过，保证在 bash -e 下不中断
FIX() {
	local NAME=$1
	local GUARD=$2
	shift 2

	[ -d "$GUARD" ] || return 0

	echo " "
	if "$@"; then
		echo "$NAME has been fixed!"
	else
		echo "$NAME fix failed; continuing!"
	fi
}

#修改argon主题字体和颜色
FIX "theme-argon" "$PACKAGE_PATH/luci-theme-argon" sed -i \
	"s/primary '.*'/primary '#31a1a1'/g; s/'0.2'/'0.5'/g; s/'none'/'bing'/g; s/'600'/'normal'/g" \
	"$PACKAGE_PATH/luci-theme-argon/luci-app-argon-config/root/etc/config/argon"

#修改aurora菜单式样
FIX "theme-aurora" "$PACKAGE_PATH/luci-app-aurora-config" find \
	"$PACKAGE_PATH/luci-app-aurora-config/root/usr/share/aurora/" -type f -name '*.template' -exec sed -i \
	"s/nav_type '.*'/nav_type 'dropdown'/g; s/struct_radius_base '.*'/struct_radius_base '0.125rem'/g" {} +

#修改vantage进度条标签字体（anothaDev/luci-theme-vantage#52）
FIX "theme-vantage" "$PACKAGE_PATH/luci-theme-vantage" sed -i \
	-e '/^\/\* progress bars: thin track/,$ { /^\.cbi-progressbar::before {/,/^}/ { s/^[[:space:]]*font: 500 var(--fs-micro)\/1\.2 var(--mono);/\tfont: inherit; line-height: normal;/; } }' \
	"$PACKAGE_PATH/luci-theme-vantage/luci-theme-vantage/htdocs/luci-static/vantage/vantage.css"

#LAN与上游WAN同网段时自动启用中继AP模式，拓扑不满足时回退上游改网段逻辑
FIX "auto-relay-ap" "$PACKAGE_PATH/emortal/luci-app-router-tool" patch -p1 \
	-d "$PACKAGE_PATH/emortal/luci-app-router-tool" \
	-i "$GITHUB_WORKSPACE/Scripts/patches/001-auto-relay-ap.patch"

#5.8G无线固定非DFS信道149，避免自动信道落入雷达信道导致5.8G不广播；5.2G保持上游默认
FIX "wireless-58g-nodfs" "$PACKAGE_PATH/emortal/luci-app-router-tool" patch -p1 \
	-d "$PACKAGE_PATH/emortal/luci-app-router-tool" \
	-i "$GITHUB_WORKSPACE/Scripts/patches/002-wireless-58g-nodfs.patch"

#软件包管理器允许安装未签名/第三方apk
FIX "apk-allow-untrusted" "$FEEDS_PATH/luci/applications/luci-app-package-manager" patch -p1 \
	-d "$FEEDS_PATH/luci/applications/luci-app-package-manager" \
	-i "$GITHUB_WORKSPACE/Scripts/patches/003-apk-allow-untrusted.patch"

#firewall4默认配置补flow offload/hw offload=1：上游默认缺省即关闭，router-tool一次性预设失败时PPE/NSS不offload
FIX "firewall4-offload-default" "$PACKAGE_PATH/network/config/firewall4" cp \
	"$GITHUB_WORKSPACE/Scripts/patches/008-default-enable-flow-offload.patch" \
	"$PACKAGE_PATH/network/config/firewall4/patches/008-default-enable-flow-offload.patch"
