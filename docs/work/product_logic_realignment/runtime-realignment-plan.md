# 羽搭运行模型替换 Plan Spec

plan_state: completed
plan_mode: full-create
updated_at: 2026-08-27

# 0. Context

## Current System

当前 Flutter App 已有球局库、名单准备和五个现场底部导航页。`PlaySession` 是聚合根，Drift 事务保存整场快照；但运行模型仍以 `SessionPlayer.queueOrder`、比赛内临时 `Team` 和 `finishMatch` 后四人统一回队为核心。Court UI 是普通 A/B 信息卡。

## Existing Problems

- 旧模型不能表达跨比赛持续存在的 `PairingGroup`。
- 随机/手动组队与随机/手动上场排序没有独立动作。
- 比分保存直接结束比赛，没有 `awaiting_rotation`。
- 不能表达 `winner_stays`、`all_rotate` 和 `waiting_opponent`。
- 数据库缺少组 owner，无法恢复组身份和组队列。
- 场地 UI 没有两侧站位、四人空间关系、比分和轮转动作。

## Constraints

- 以 `docs/knowledge/product/badminton-session-organizer.md` 为唯一产品逻辑来源。
- 保留现有五个底部导航，不新增路由或账号、网络、单打、逐球计分能力。
- `PlaySession` 继续作为唯一业务聚合根，`PlaySessionStore.update` 继续提供事务边界。
- 不新增 UI、图标、动画或状态管理依赖；复用现有 Theme、SVG 图标与 Material 原语。
- Drift 迁移必须非破坏：保留历史比赛；旧 active 的 ready/inProgress 对阵转成持续组；无法推断搭档的旧 waiting 玩家转为 ungrouped。

## Why Now

用户已确认现有骨架正确，但业务流转和场地表达不符合需求。继续在旧模型上补页面会固化错误 owner 和状态语义。

## Long-term Direction

玩家先形成持续双人组，组按稳定队列进入具象场地；比分完成后显式决定留场或全部下场，并在一个原子动作中更新比赛、场地和队列。

# 1. Intent

用新产品基线替换旧个人候场模型，使组织者可以完成“玩家与场地准备 → 随机/手动组队 → 随机/手动排序 → 分配具体场地 → 记录比分 → 决定上下场 → 继续下一场”的完整本地闭环。

# 2. Non-Goals

- 不实现联网、登录、多设备同步、通知、费用、赛事、排名或单打。
- 不实现逐球实时计分；只保存胜方或各局最终比分。
- 不改五个现场底部导航的数量和路由语义。
- 不为未来扩展预建通用 workflow engine、event bus、repository 分层或第二套状态管理。
- 不自动回滚比分修正后已经发生的历史轮转。
- 不重新设计项目图标家族或配色体系。

# 3. Boundaries

## Allowed

- `lib/play_session/`：领域实体、动作、状态校验、快照和统计。
- `lib/rally_pair_helper/fd_rally_pair_db/`：组表、字段、schema v4 迁移和快照映射。
- `lib/session_library/`：新建球局设置中的默认轮转和场地准备语义。
- `lib/session_flow/`：组队、组候场、具象场地、比分与轮转交互。
- 对应 `test/`：domain、snapshot、Drift 和 widget/flow 回归测试。
- `docs/work/product_logic_realignment/` 与 `docs/status/current.md`：计划、执行和进度证据。

## Forbidden

- `lib/rally_pair_helper/` 其他迁移框架模块、网络、权限、媒体、缓存和路由基础设施。
- 新增第三方依赖、全局 service locator、singleton 或并行 state store。
- 在 Widget 内复制组队列、场地占用或轮转业务状态。
- 用 `first/current/default item` 捷径代替指定玩家、组、场地或比赛动作。
- 删除旧数据库或静默丢弃历史比赛。

# 4. Ownership

- `PlaySession`：唯一 action owner，负责玩家、组、场地、比赛、轮转和跨实体原子状态。
- `PairingGroup`：持有两名成员、状态和组候场顺序；不由 Match 或 Widget 临时创建语义替代。
- `SessionMatch`：持有场地、两组与四人快照、结果和实际轮转方式。
- `Court`：持有场地身份、当前 Match 和可选 staying 组。
- `FdPlaySessionStore`：持久化映射与单事务写入，不决定业务状态。
- 页面/Pane：只读取聚合快照并触发指定 action，不拥有业务真相。

# 5. Architecture Constraints

- 保持 `UI -> PlaySessionStore.update -> PlaySession action -> snapshot -> Drift transaction` 的最短调用链。
- 新状态使用业务词：`ungrouped/grouped`、`waiting/assigned/playing/awaitingRotation/staying`、`ready/inProgress/resultRecorded/completed/canceled`、`available/ready/inPlay/awaitingRotation/waitingOpponent`。
- 每次成功动作只保存一次完整一致快照；失败不得留下半组、半比赛或半轮转。
- Match 保存成员快照，后续等待组换人不改写历史比赛。
- schema v4 迁移只增加新结构并兼容读取旧行，不清库。
- 具象场地使用本地 Widget/Painter 与现有颜色，不引入图片或新依赖。

# 6. Plan Checklist

## Plan Unit 1 — 聚合根与非破坏持久化替换

### WHY

没有持续组 owner 和可恢复快照，后续页面只能继续模拟旧流程。

### IMPLEMENTATION

替换旧 `PairingPolicy/Team` 运行依赖，新增 `PairingGroup`、新状态和组级 queueOrder；更新 snapshot、Drift 表与 schema v4。兼容旧历史与当前对阵，禁止清库迁移。

### WHERE

Owner：`PlaySession`、`FdPlaySessionStore`。允许 `lib/play_session/`、`lib/rally_pair_helper/fd_rally_pair_db/` 和对应测试；禁止 UI 提前创建未来动作入口。

### VALIDATION

新旧快照均能加载；随机五人只生成两组；同一玩家不能属于两个有效组；事务失败保留旧快照。

### REGRESSION

保留玩家唯一名称、64 人上限、1–8 场地、比分规则、历史统计和删除原子性。

### HANDOFF

交付新实体、snapshot v4、旧数据兼容测试和明确 action inventory，供现场页逐阶段接入。

## Plan Unit 2 — 组队与组候场顺序闭环

### WHY

用户必须分别控制“谁和谁一组”和“哪组先上”。

### IMPLEMENTATION

实现随机/手动组队、waiting 组换人/解散、随机排序和指定组手动移动；准备页在至少两组和一块场地后允许启动。

### WHERE

Owner：`PlaySession`；UI：名单准备、GroupingWorkspace、RotationWorkspace。禁止排序 assigned/playing/awaitingRotation/staying 组。

### VALIDATION

奇数玩家留在 ungrouped；指定非首组可换人、解散和移动；重启后顺序一致。

### REGRESSION

测试不得使用 first-item shortcut；每项编辑覆盖指定 ID 和状态锁定失败路径。

### HANDOFF

交付稳定 waitingGroups、组队入口和可恢复 queueOrder，供场地分配消费。

## Plan Unit 3 — 具体场地分配与比赛状态

### WHY

组只有进入具体 Court 后，现场组织者才能确认当前对阵和比赛状态。

### IMPLEMENTATION

实现动态场地增删、按队首/指定组分配、开赛、取消、胜方或局分录入，并引入 `resultRecorded/awaitingRotation` 中间态。

### WHERE

Owner：`PlaySession`、`SessionMatch`、`Court`；UI：CourtWorkspace 与结果录入 Dialog。禁止比分提交直接释放场地。

### VALIDATION

多场地无重复组；只有一组时不创建比赛；无效比分不改变状态；指定非首场地动作有效。

### REGRESSION

保留取消比赛不计统计、结果修正全量重算和 Match 成员快照稳定性。

### HANDOFF

交付 `Court.awaitingRotation` 和已保存结果，供上下场决策原子消费。

## Plan Unit 4 — 双模式上下场轮转

### WHY

比分不是现场流程终点，必须决定谁留、谁下和下一组是谁。

### IMPLEMENTATION

实现 `winnerStays`、`allRotate`、留场补位和释放留场场地；本轮刚下场组从当前补位候选中排除。

### WHERE

Owner：`PlaySession`；UI：具体 Court 的轮转决策和 RotationWorkspace。禁止用 UI 顺序或临时 list 模拟轮转。

### VALIDATION

候场充足和不足两类 fixture 均闭合；下一场创建、原场完成、组队列和场地状态一次写入；写入失败全部回滚。

### REGRESSION

刚下场组不得即时重赛；waitingOpponent 只能有一组 staying；有未决轮转不得结束球局。

### HANDOFF

交付完整多轮循环和完成球局前的可释放出口。

## Plan Unit 5 — 具象化场地与全链路验收

### WHY

普通 A/B 卡片无法让组织者快速理解场地、站位、比分和下一动作。

### IMPLEMENTATION

在保留五导航骨架下，将 CourtWorkspace 改为标准羽毛球场对象；两组位于网两侧、四名玩家位置稳定，比分、状态和动作依附同一场地。补齐窄屏、文本缩放和五种 Court 状态。

### WHERE

Owner：UI renderer；允许 `live_session_court_pane.dart` 及其最小同域组件、Widget tests。不得改变业务状态或引入新视觉依赖。

### VALIDATION

available、ready、inPlay、awaitingRotation、waitingOpponent 均有 Widget 测试；窄屏无 overflow；完整流程能从组队走到第二场开赛。

### REGRESSION

具象场地、两侧站位和依附场地动作成为固定测试断言，禁止退化为独立 A/B 信息卡。

### HANDOFF

交付真实 Flutter 页面、domain/storage/widget 测试以及剩余非阻塞风险。

# 7. Validation

- `fvm dart format` 仅格式化本次修改的 Dart 文件。
- `fvm flutter analyze` 必须 0 error。
- `fvm flutter test` 必须全部通过。
- `fvm flutter test test/play_session/session_test.dart` 覆盖状态机。
- `fvm flutter test test/rally_pair_helper/fd_rally_pair_db/fd_play_session_store_test.dart` 覆盖 schema 与恢复。
- `fvm flutter test test/widget_test.dart` 覆盖组队、场地和轮转可见入口。
- `git diff --check` 与 docs-keeper 检测必须通过。

# 8. Failure Handling

- 领域 guard 失败：抛稳定 `RuleViolation`，聚合和数据库保持旧状态，UI 显示可恢复原因。
- Drift 迁移失败：不删除旧表；App 返回可诊断错误，不创建部分 v4 数据。
- 旧 active 无法推断候场搭档：保留玩家但设为 ungrouped，要求重新组队；不伪造固定组。
- 轮转事务失败：保留 `resultRecorded/awaitingRotation`，允许重试。
- UI 验证失败：不以 analyzer 通过替代状态可见性，修复后重跑对应 Widget test。

# 9. Regression Protection

- 固定种子随机组队和排序必须可重复。
- 所有指定项 CRUD/排序测试至少覆盖非首项。
- snapshot restore 检查 player/group/court/match 唯一性与跨实体引用。
- schema v3 fixture 升级到 v4 后历史比赛数和比分不变。
- 每种轮转包含候场足够/不足和“刚下场组不即时补位”测试。
- Court renderer 对五状态、两侧四人、比分和动作建立 key/semantics 断言。

# 10. Progress State / Handoff State

## Current Phase

P1–P7 已完成实现和闭环校验，当前进入交付状态。

## Completed

- 产品基线已修订为持续双人组与双模式轮转。
- 跨阶段运行模型决策已 accepted。
- 旧 domain、Drift 和五个现场 pane 已完成代码盘点。
- P1–P7 的 31 个 runtime action 已落入领域、持久化和用户可见入口。
- schema v4、旧 v3 活动恢复、具象 Court UI 和两种轮转模式已通过测试。

## In Progress

无。

## Blocked

无。

## Next Actions

在真实设备上做交互手感复核；后续需求继续以当前运行模型为基线，不回退到个人临时候场模型。

## Decisions Made

- 五导航骨架保留。
- 非破坏 schema v4 兼容，不清库。
- 不新增依赖；具象球场由 Flutter 原生绘制。

## Open Questions

无阻塞问题。比赛耗时等扩展继续留在 V1 外。

## Last Known Good State

2026-08-27：`fvm flutter analyze` 0 issues；全量 Flutter tests 通过；schema v3 fixture、状态机、持久化和 Widget tests 均有新模型证据。

## Files / Modules Touched

实现范围覆盖 `lib/play_session/`、`lib/rally_pair_helper/fd_rally_pair_db/`、球局库/准备/现场页面与对应测试，未新增依赖或路由。

## Validation Status

Plan Spec Full Gate=PASS；实现验证与 docs-keeper 检测结果见 Execution Spec closure。

## Handoff Notes

Execution Spec 已完成；新增能力必须继续沿用 PairingGroup、Court、Match 和 PlaySession 聚合边界。
