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

- 登录地址：`192.168.10.1`，密码：无（首次登录自行设置）
- 主机名 / WIFI 名称：`YkingWrt`，WIFI 密码：`12345678`
- 主题：`vantage`，语言：简体中文

以上默认值在 `.github/workflows/QCA-ALL.yml` 的 `with` 参数中修改。

## 自定义

- 新增设备：在 `Config/IPQ60XX-WIFI-YES.txt` 追加 `CONFIG_TARGET_DEVICE_qualcommax_ipq60xx_DEVICE_<profile>=y`。
- 增删插件：修改 `Config/GENERAL.txt`，或手动触发时用 `PACKAGE` 输入框临时调整。
- 私有配置：新建 `Config/PRIVATE.txt`（追加到 .config）与 `Scripts/PRIVATE.sh`（Packages.sh 末尾 source），两者均被自动引入且不影响上游格式。
- 新增平台：参照 `Config/` 现有命名添加配置 txt，并在 `QCA-ALL.yml`（或新建调用 yml）的 matrix 中加入对应 CONFIG。

## 与上游 OpenWRT-CI 的差异

- 设备列表仅保留京东云亚瑟、雅典娜两款。
- Auto-Clean 保留最近 2 个 Release、7 天运行记录（上游为全部删除）。

## 说明

- 刷机有风险，请确认机型与镜像匹配（factory 用于原厂系统刷入，sysupgrade 用于 OpenWrt 升级）。
- 源码与 CI 格式版权归 VIKINGYFY，MIT 许可，见 `LICENSE`。