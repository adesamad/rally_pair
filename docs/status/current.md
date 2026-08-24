# Current Status

doc_profile: docs-keeper

## Read First

- [羽搭 / RallyPair 产品方向基线](../knowledge/product/badminton-session-organizer.md)
- [图标库视觉方向决策](../decisions/icon-library-visual-direction.md)
- [第一批语义图标 HTML 图标墙](../work/icon_library/rally-pair-icon-batch-01.html)
- [图标与配色 HTML 风格板](../work/icon_library/rally-pair-icon-palette-preview.html)
- [文档目录与维护约定](../README.md)

## Current Focus

| work | state | read first | next |
| --- | --- | --- | --- |
| framework_migration | done | docs/work/framework_migration/code-move-constraint-report.md | 迁移框架保持独立模块；真实 App 入口由后续业务实现负责 |
| icon_library | doing | docs/work/icon_library/rally-pair-icon-batch-01.html | 审阅第一批 12 个 SVG 图标，淘汰或修订 24px 下识别不足的图案 |

## Current Baselines

| domain | file | document_state |
| --- | --- | --- |
| product | docs/knowledge/product/badminton-session-organizer.md | accepted |
| icon_design | docs/decisions/icon-library-visual-direction.md | accepted |

## Archived Releases

当前没有已归档版本。

## Recent Changes

- 2026-08-24：删除无真实消费者且与 App 入口职责重复的 `am_rally_pair_main`；迁移范围不再包含第二套 App 根壳和启动接线。
- 2026-08-24：按模板原目录归属重新整理迁移模块，仅叠加已冻结前缀与 `rally_pair` 关键字；移除误加的 `lib/app`、`lib/shared` 分层。
- 2026-08-24：按模板迁移指南完成日志、Dio、网络、App 配置、路由、Hive、Drift、输入、弹层、权限与媒体共 11 个独立模块迁移；Android/iOS 构建通过。
- 2026-08-24：移除已失效的 `mt_rally_pair_main` 壳层与旧架构 Spec；`lib/main.dart` 继续保持未接线状态。
- 2026-08-23：将已确认图标风格提升为项目级强制规范，后续生成与修改必须遵循统一 SVG、笔画、配色和 24px 验证约束。
- 2026-08-23：生成第一批 12 个可编辑 SVG 语义图标及项目内 HTML 图标墙。
- 2026-08-23：确认“天空与草地”配色和五组图标结构，登记图标库视觉决策并修正标准羽毛球场线。
- 2026-08-23：新增项目内图标与配色 HTML 风格板，进入图标库视觉方向选择阶段。
- 2026-08-23：将产品方向文档路由为当前产品基线，并登记图标库为下一开发方向。
- 2026-08-23：在项目级 `AGENTS.md` 中声明默认使用 docs-keeper 管理文档。
- 2026-08-23：初始化 docs-keeper 基础文档管理结构与当前状态入口。
