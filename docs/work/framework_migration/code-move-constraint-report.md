# Framework Migration Report

report_state: completed

## Scope

依据 `/Users/ycwb/my/github/hy/hy_mj/docs/template_migration_guide.md`，从模板工程按独立模块迁移可复用框架与基础工具。目标关键字固定为 `rally_pair`，每个模块使用独立两字母随机前缀。

## Module Decisions

| prefix | source | target | decision |
| --- | --- | --- | --- |
| `cv` | `packages/mj_log` | `packages/cv_rally_pair_log` | 迁移加密日志、脱敏、轮转、读取和双端原生目录桥接；重写 package、类型、channel 与日志格式身份 |
| `mh` | `packages/mj_dio` | `packages/mh_rally_pair_dio` | 迁移 Dio 配置、请求、响应、异常和调试拦截器 |
| `us` | `lib/mj_dio` 的 config/interceptor | `lib/us_rally_pair_dio` | 重写为调用方注入 `baseUrl`；不迁移模板业务 API 与模型 |
| `zf` | `lib/mj_app` | `lib/zf_rally_pair_app` | 只迁移安全 App 身份和空值扩展；删除端点、密钥、推送配置 |
| `ig` | `lib/mj_router/mj_router.dart` | `lib/ig_rally_pair_router` | 保留通用 Navigator 能力；删除绑定模板页面的 RouterHelper |
| `qk` | `lib/mj_helper/mj_cache` | `lib/qk_rally_pair_cache` | 迁移 Hive 读写；使用新 box 名；源 AES key 不复制，改为可选注入 |
| `fd` | `lib/mj_helper/mj_db` | `lib/fd_rally_pair_db` | 迁移 Drift 连接、事务、关闭和 codegen；排除示例表与示例 CRUD |
| `rt` | `lib/mj_widgets/mj_input` | `lib/rt_rally_pair_input` | 迁移输入控件与 controller ownership；视觉改用目标 Theme |
| `sw` | `lib/mj_helper/mj_dialog` | `lib/sw_rally_pair_dialog` | 迁移 dialog、loading、bottom edit；视觉改用目标 Theme |
| `ks` | `lib/mj_helper/mj_pms` | `lib/ks_rally_pair_pms_helper` | 迁移相机、麦克风、照片、视频、文件权限和设备版本判断；删除通知权限 |
| `ft` | `lib/mj_widgets/mj_media` | `lib/ft_rally_pair_media` | 迁移拍照、相册、录像、文件选择和媒体预览 |

所有模块均提供同名目录内 barrel export。

## Template-Aligned Directory Structure

目标目录保持模板原有归属，只在模块名中加入已经冻结的前缀与 `rally_pair` 关键字：

```text
lib/
├── zf_rally_pair_app/
│   ├── zf_rally_pair_config/
│   └── zf_rally_pair_extension/
├── us_rally_pair_dio/
│   ├── us_rally_pair_dio_config/
│   └── us_rally_pair_dio_interceptor/
├── rally_pair_helper/
│   ├── qk_rally_pair_cache/
│   ├── fd_rally_pair_db/
│   ├── sw_rally_pair_dialog/
│   │   └── sw_rally_pair_bottom_dialog/
│   └── ks_rally_pair_pms_helper/
├── ig_rally_pair_router/
└── rally_pair_widgets/
    ├── rt_rally_pair_input/
    └── ft_rally_pair_media/
```

`packages/cv_rally_pair_log` 与 `packages/mh_rally_pair_dio` 继续作为独立本地 package。目标工程不额外引入 `app/shared` 分层，也不创建被排除能力的空目录。

## Excluded

- WebView 与 JS bridge。
- 推送、个推 SDK、通知权限和厂商配置。
- 下载工具。
- 通用加解密工具；仅保留诊断日志内部格式所需的认证加密。
- 模板业务 API、用户/验证码模型、远程 Back 认证、Home/Feedback 页面。
- 模板端点、日志密钥、推送密钥、生成资源与 Drift 示例表。

## Target Adaptations

- `lib/main.dart` 按迁移指南保持不变；不迁移模板 `main.dart` 中的 App 根壳、全局初始化与启动接线。
- Android 只声明网络、相机、录音、图片、视频和旧系统存储兼容权限；未声明通知或 WebView 配置。
- iOS 声明相机、麦克风、照片读取/写入用途，并只启用对应 `permission_handler` 宏。
- 缓存密钥、网络地址和日志密钥都由目标调用方提供，不保留模板秘密。
- Drift 固定使用经模板验证的 `2.32.1` 版本组合，并生成目标数据库代码。
- 媒体预览中的 Material 系统图标仅为功能占位，代码已标记 `TODO(icon-system)`，后续按图标视觉决策统一替换。

## Validation

| check | result |
| --- | --- |
| `fvm flutter pub get` | PASS |
| Drift build_runner | PASS |
| `fvm flutter analyze` | PASS，0 issues |
| `fvm flutter test` | PASS，4 tests |
| `fvm flutter build apk --debug` | PASS |
| `fvm flutter build ios --debug --no-codesign` | PASS |
| 模板身份残留扫描 | PASS |
| WebView / 推送 / 下载依赖检查 | PASS |
| 模板同构目录与旧 `app/shared` 路径检查 | PASS |

## App Entry Boundary

本次不保留 `am_rally_pair_main`，也不为迁移框架创建第二套 App 根壳。后续真实产品入口、首页和启动初始化由目标工程按业务实现负责；网络地址、可选缓存 key 与日志 key 仍由目标方提供，本次未生成或复制任何秘密。
