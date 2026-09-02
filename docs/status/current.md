# Current Status

doc_profile: docs-keeper

## Read First

- [羽搭 / RallyPair 产品方向基线](../knowledge/product/badminton-session-organizer.md)
- [双人组、场地与上下场轮转运行模型决策](../decisions/group-court-rotation-runtime-direction.md)
- [单场地、单双打与一局比分运行模型决策](../decisions/single-court-match-format-runtime-direction.md)
- [现场球局单工作台与连续推进决策](../decisions/live-session-workspace-direction.md)
- [图标库视觉方向决策](../decisions/icon-library-visual-direction.md)
- [第一批语义图标 HTML 图标墙](../work/icon_library/rally-pair-icon-batch-01.html)
- [图标与配色 HTML 风格板](../work/icon_library/rally-pair-icon-palette-preview.html)
- [文档目录与维护约定](../README.md)

## Current Focus

| work | state | read first | next |
| --- | --- | --- | --- |
| product_logic_realignment | done | docs/work/product_logic_realignment/runtime-realignment-plan.md、docs/work/product_logic_realignment/runtime-realignment-execution-spec.md | 在真实设备复核具象场地、长名单与轮转操作手感；后续功能沿用当前运行模型 |
| single_court_formats | done | docs/work/single_court_formats/requirement-logic-impact.md、docs/decisions/single-court-match-format-runtime-direction.md | 在真实设备走查单打/双打连续轮转与比分录入手感 |
| live_session_workspace | done | docs/work/live_session_workspace/rotation-policy-impact.md、docs/decisions/live-session-workspace-direction.md | 在真实设备连续完成多场，确认创建时选定的轮换方式自动执行且结算无重复选择 |
| session_summary | done | docs/work/session_summary/player-performance-impact.md | 在真实设备复核单打小样本、双打多人和部分未记比分时的扫读效果 |
| framework_migration | done | docs/work/framework_migration/code-move-constraint-report.md | 迁移框架保持独立模块；真实 App 入口由后续业务实现负责 |
| icon_library | doing | docs/work/icon_library/rally-pair-icon-batch-01.html | 审阅第一批 12 个 SVG 图标，淘汰或修订 24px 下识别不足的图案 |

## Current Baselines

| domain | file | document_state |
| --- | --- | --- |
| product | docs/knowledge/product/badminton-session-organizer.md | accepted |
| runtime_model | docs/decisions/group-court-rotation-runtime-direction.md | accepted |
| match_format_model | docs/decisions/single-court-match-format-runtime-direction.md | accepted |
| live_session_interaction | docs/decisions/live-session-workspace-direction.md | accepted |
| icon_design | docs/decisions/icon-library-visual-direction.md | accepted |

## Archived Releases

当前没有已归档版本。

## Recent Changes

- 2026-09-02：球局总结改为先呈现完成场数、上场覆盖、人均出场与轮转均衡提示；球友表现只展示实际参赛者的出场、胜负、胜率和可靠净胜分，未上场者独立说明，比赛记录降权展开。
- 2026-09-02：轮换方式提升为创建球局时直接可见且必选的整场规则；开局后冻结，每场结算只录胜方或比分并自动按球局规则轮转，取消单场覆盖。
- 2026-09-02：现场球局收敛为单一工作台；开始首场合并启动/分配/开赛，比赛结算合并结果与轮转并实际应用默认轮转方式，结束球局统一收尾未决状态；保留旧多场地兼容。
- 2026-08-30：完成单场地、单双打与一局比分实现：新建和复制固定一块场地，单打采用个人候场，双打保留固定组，schema v5 非破坏兼容旧多场地/旧多局数据；Flutter analyze 与 50 项 tests 全部通过。
- 2026-08-30：确认 V1 收敛为单场地；新建时选择单打或双打；11 分和 21 分都只记录一局；旧多场地与旧多局数据非破坏兼容。

- 2026-08-27：完成 P1–P7 运行模型替换：固定双人组、组队列、具名场地、具象 Court UI、比分记录、胜方留场/两组下场、历史修正与球局收尾均已接入，schema v3→v4 非破坏迁移和全量 Flutter tests 通过。
- 2026-08-27：生成运行模型替换 Plan Spec 与 Execution Spec，将 31 个 runtime action 拆为 7 个可见 vertical slice，并冻结非破坏 schema v4 兼容策略。
- 2026-08-27：将产品基线从个人候场与临时队伍修订为持续双人组、组候场队列、分场地比分和 winner_stays / all_rotate 双模式轮转。
- 2026-08-27：确认具象化羽毛球场为 CourtWorkspace 核心业务对象，禁止继续用仅含 A/B 文本的普通卡片作为最终场地表达。
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
