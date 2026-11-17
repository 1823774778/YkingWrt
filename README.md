# YkingWrt

基于 [VIKINGYFY/immortalwrt](https://github.com/VIKINGYFY/immortalwrt)（`owrt` 分支，IPQ 系列带满血 PPE/NSS 驱动）的 OpenWrt 云构建源，使用 GitHub Actions 自动编译固件。

## 支持设备

| 设备 | 型号 | SoC | Profile | 配置文件 |
| --- | --- | --- | --- | --- |
| 京东云亚瑟 | JDCloud AX1800 Pro (RE-SS-01) | IPQ6000 | `jdcloud_re-ss-01` | `configs/jdcloud_re-ss-01.config` |
| 京东云雅典娜 | JDCloud AX6600 (RE-CS-02) | IPQ6010 + QCN9074 | `jdcloud_re-cs-02` | `configs/jdcloud_re-cs-02.config` |

## 使用方法

1. 打开仓库的 **Actions** 页面，选择 **Build YkingWrt**，点击 **Run workflow** 手动触发（两台设备并行编译）。
2. 编译完成后在该次运行的 **Artifacts** 中下载对应设备的固件；手动触发的构建还会自动发布到 **Releases**。
3. 修改 `configs/`、`scripts/` 或工作流文件并推送到 `main` 分支时也会自动触发构建。

## 自定义

- `configs/<profile>.config`：设备种子配置，可追加软件包（`CONFIG_PACKAGE_xxx=y`）。
- `scripts/diy-part1.sh`：feeds 更新前执行（如添加第三方软件源）。
- `scripts/diy-part2.sh`：feeds 安装后执行（如修改默认 IP、精简插件）。

## 说明

- 上游源码每次构建时浅克隆最新 `owrt` 分支。
- 刷机有风险，请确认机型与镜像匹配（factory 用于原厂系统刷入，sysupgrade 用于 OpenWrt 升级）。