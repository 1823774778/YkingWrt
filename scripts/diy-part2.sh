#!/bin/bash
# 在 feeds install 之后、生成 .config 之前执行，工作目录为 openwrt 源码根目录
# 可在此修改源码默认设置、替换/新增插件等
# 环境变量 DEVICE_PROFILE 为当前构建的设备 profile 名

# 示例：修改默认 LAN IP
# sed -i 's/192.168.1.1/192.168.10.1/g' package/base-files/files/bin/config_generate