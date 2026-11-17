#!/bin/bash
# 在 feeds update 之前执行，工作目录为 openwrt 源码根目录
# 可在此修改 feeds.conf.default、添加第三方软件源等
# 环境变量 DEVICE_PROFILE 为当前构建的设备 profile 名

# 示例：添加自定义软件源
# echo 'src-git custom https://github.com/<user>/<packages-repo>.git' >> feeds.conf.default