# YkingWrt

基于 [VIKINGYFY/immortalwrt](https://github.com/VIKINGYFY/immortalwrt)（`owrt` 分支，IPQ 系列带满血 PPE/NSS 驱动）的 OpenWrt 云构建项目，目录与工作流格式参照 [VIKINGYFY/OpenWRT-CI](https://github.com/VIKINGYFY/OpenWRT-CI)。

## 支持设备

| 设备 | 型号 | SoC |
| --- | --- | --- |
| 京东云亚瑟 | JDCloud AX1800 Pro (RE-SS-01) | IPQ6000 |
| 京东云雅典娜 | JDCloud AX6600 (RE-CS-02) | IPQ6010 + QCN9074 |

设备列表见 `Config/IPQ60XX-WIFI-YES.txt`，一次编译输出平台内全部设备固件（MULTI_PROFILE）。

## 目录结构

```
.github/scripts/      编译辅助脚本（主机工具链、Rust 预置、i2c-tools、编译报告）
.github/workflows/    WRT-CORE 公用编译核心 + QCA-ALL 调用入口 + 清理任务
Config/               GENERAL.txt 通用配置 + 各平台设备配置
Scripts/              Packages.sh 插件更新 / Handles.sh 修补 / Settings.sh 默认设置
```

## 使用方法

1. **Actions** 页面选择 **QCA-ALL**，点击 **Run workflow** 手动编译；`TEST` 勾选后仅输出配置文件不编译。
2. 编译完成后固件自动发布到 **Releases**（含登录地址、WIFI、内核版本、插件列表等信息）。
3. 每天北京时间约 5:21 **Auto-Clean** 清理旧 Release/运行记录后自动触发新一轮编译；**Cache-Clean** 每周清理编译缓存。

## 默认设置

- 登录地址：`10.10.10.1`，密码：无（首次登录自行设置）
- 主机名 / WIFI 名称：`YkingWrt`，WIFI 密码：`12345678`
- 主题：[vantage](https://github.com/anothaDev/luci-theme-vantage)（main 分支），语言：简体中文
- 内置 `luci-app-wifiroam` + `wifiroam`（来自 [1823774778/meshzw](https://github.com/1823774778/meshzw)，拓扑视图与 802.11k/v/r 无缝漫游）
- 内置 `luci-app-xwrt-ota`（来自 [1823774778/openwrt-ota](https://github.com/1823774778/openwrt-ota)，系统 → 在线更新：读取本仓库 Latest Release、按设备匹配 sysupgrade、SHA256 校验后刷写）；构建时写入 `/etc/xwrt-build-time`（与 Release 标签时间同源）供版本比较
- 不含 homeproxy、gecoosac、natmapt
- 自动中继AP：LAN 与上游 WAN 下发地址同网段时，自动启用接口页（admin/network/network）的"中继AP模式"（桥接全部网口、LAN 改 DHCP、关闭本机 DHCP）；端口拓扑不满足条件时回退上游的自动改 LAN 网段逻辑。补丁见 `Scripts/patches/001-auto-relay-ap.patch`，由 Handles.sh 应用
- 5.8G 修复：无线初始化时 5.8G 固定非 DFS 信道 149，避免自动信道落入雷达信道后 5.8G 不广播（`002-wireless-58g-nodfs.patch`）；5.2G 保持上游默认不做修改。仅对未配置过的无线生效，已配置设备请在 LuCI 无线页手动改信道或不保留配置重刷
- apk 任意安装：软件包管理器（含"Upload Package…"上传安装）附加 `--allow-untrusted`，可安装未签名/第三方 apk（`003-apk-allow-untrusted.patch`）
- 不含 mini-diskmanager、wolultra、samba4、homeproxy、gecoosac、natmapt
- 硬件加速默认开启：firewall4 上游默认配置不含 flow offload 选项（缺省即关），靠 router-tool 一次性预设开启且失败不重试；本构建以源码补丁 `008-default-enable-flow-offload.patch` 在编译期给默认配置补 `flow_offloading=1`、`flow_offloading_hw=1`，全新刷机即硬 offload，无运行时脚本
- 自动中继AP 带 syslog 诊断：转换被跳过时记录原因（`logread | grep router-tool` 可查看）

以上默认值在 `.github/workflows/QCA-ALL.yml` 的 `with` 参数中修改。

## 自定义

- 新增设备：在 `Config/IPQ60XX-WIFI-YES.txt` 追加 `CONFIG_TARGET_DEVICE_qualcommax_ipq60xx_DEVICE_<profile>=y`。
- 增删插件：修改 `Config/GENERAL.txt`，或手动触发时用 `PACKAGE` 输入框临时调整。
- 私有配置：新建 `Config/PRIVATE.txt`（追加到 .config）与 `Scripts/PRIVATE.sh`（Packages.sh 末尾 source），两者均被自动引入且不影响上游格式。
- 新增平台：参照 `Config/` 现有命名添加配置 txt，并在 `QCA-ALL.yml`（或新建调用 yml）的 matrix 中加入对应 CONFIG。

## 与上游 OpenWRT-CI 的差异

- 设备列表仅保留京东云亚瑟、雅典娜两款。
- Auto-Clean 保留最近 2 个 Release、7 天运行记录（上游为全部删除）。
- 默认地址 10.10.10.1；增删插件与自动中继AP补丁见上文"默认设置"。

## 说明

- 刷机有风险，请确认机型与镜像匹配（factory 用于原厂系统刷入，sysupgrade 用于 OpenWrt 升级）。
- 源码与 CI 格式版权归 VIKINGYFY，MIT 许可，见 `LICENSE`。