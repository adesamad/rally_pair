# 球局级轮换规则影响分析

document_state: accepted_for_implementation
analysis_mode: feature-impact-analysis

## 1. Requested Change

把轮换方式从“每场比赛结算时重新选择”改为“创建球局时设置、整场自动执行”。

## 2. Feature Classification

- Runtime Required：创建或调整 draft 球局时选择 `winnerStays` 或 `allRotate`。
- Runtime Required：每场结果提交后自动应用球局的 `defaultRotationMode`。
- Removed from V1：单场临时覆盖轮换方式。
- Runtime Support：旧 `resultRecorded` 恢复状态按球局规则继续完成轮转。

## 3. Impacted Logic Chain

```text
创建球局并选择轮换方式
-> 添加玩家、组队和排序
-> 开始第一场并冻结球局设置
-> 每场只提交胜方或比分
-> PlaySession 自动应用 defaultRotationMode
-> 更新候场并准备下一场
```

## 4. Runtime Action Changes

Runtime Action:
- action_id: configure_rotation_policy
- actor: LocalOrganizer
- initiation: 新建球局或编辑 draft 球局
- source state: none / PlaySession.draft
- target entity: PlaySession.setup
- preconditions: 球局尚未开始
- input fields: defaultRotationMode
- boundary checks: 值必须是 `winnerStays` 或 `allRotate`
- state transition: none -> draft / draft -> draft
- success result: 轮换方式随球局设置保存
- failure result: 不创建球局或保留旧设置
- recovery path: 重新选择后提交
- owner: PlaySession
- required test assertion: 创建结果保存明确的轮换方式

Runtime Action:
- action_id: finish_and_rotate
- actor: LocalOrganizer
- initiation: 当前比赛结束后提交胜方或比分
- source state: Match.inProgress
- target entity: Match / Court / waiting queue
- preconditions: 比赛、场地和参赛单位状态一致
- input fields: MatchResult
- boundary checks: 胜方或比分合法；球局存在受支持的 defaultRotationMode
- state transition: inProgress -> resultRecorded -> completed，并按规则生成 nextReady 或等待态
- success result: 本场完成且下一场状态已更新
- failure result: 本场保持原状态，不产生部分轮转
- recovery path: 修正结果后重试
- owner: PlaySession
- required test assertion: UI 不提交 rotationMode，完成结果仍按 setup 自动轮转

## 5. State Transition Changes

Entity: Match
- from: inProgress
  event/action: finish_and_rotate
  guard condition: MatchResult 合法且 PlaySession.defaultRotationMode 有效
  to: completed
  actor: LocalOrganizer 发起、PlaySession 执行
  side effects: 写入轮转方式、更新候场、创建下一场或进入等待态
  reversible: no；历史结果只能通过纠错修改，已发生轮转不回滚

状态枚举不变，只取消中间的人工轮换决策。

## 6. Boundary Check Changes

Boundary Check:
- action_id: configure_rotation_policy
- check_type: state
- condition: 仅 draft 球局可修改
- block result: active/completed 球局保持原设置
- feedback: 开始后按已选规则自动轮转
- recovery path: 返回 draft 时修改，或新建/复制球局
- verification assertion: active 球局无轮换设置入口

Boundary Check:
- action_id: finish_and_rotate
- check_type: ownership
- condition: rotationMode 只能来自 PlaySession.setup
- block result: UI 无法构造单场覆盖
- feedback: 结算表面只读显示本场将采用的规则
- recovery path: 取消结算继续比赛
- verification assertion: 结算弹层不存在轮换 SegmentedButton

## 7. Data Ownership Changes

- owner entity: PlaySession
- owned data: defaultRotationMode
- allowed mutations: create_session、update_draft_setup
- derived state: 每个 completed Match.rotationMode 记录实际采用的球局规则
- forbidden owner leakage: LiveSessionPage 和结算 Dialog 不自行选择或覆盖轮换方式
- required test assertion: finishAndRotate 仅接收 matchId 和 MatchResult

## 8. Permission Changes

无。仍只有 LocalOrganizer。

## 9. Lifecycle Changes

- draft：可选择并保存轮换方式。
- active：规则冻结，每场自动执行。
- completed：规则和每场实际轮转只读保留。

## 10. Surface Responsibility Changes

- SessionSetupPage：公开展示并收集轮换方式，说明整场生效与冻结时机。
- FinishMatchDialog：只收集胜方或比分，并只读提示自动采用的规则。
- LiveSessionPage：提交 MatchResult，不传 rotationMode。
- PlaySession：读取 setup、校验结果、完成轮转并准备下一场。

## 11. Entity Changes

无新实体、字段或持久化 schema。

## 12. New Failure / Recovery Paths

- 用户取消结算：比赛保持 inProgress。
- 旧快照停在 resultRecorded：点击“按球局规则继续”后完成轮转。
- 候场不足：沿用原有 waitingOpponent / available 恢复路径。

## 13. Assumptions and Unknowns

Assumption:
- assumption: active 球局不提供临时修改轮换规则。
- why low risk: 用户明确要求把决策前移，且当前产品基线已经冻结开局后的赛制设置。
- affected logic: setup、finish_and_rotate、旧状态恢复。
- validation needed: 真机连续完成多场，确认不再出现重复轮换决策。

Unknown:
- unknown: none
- affected action/state/boundary: none
- risk: none
- blocks readiness: no
- required clarification: none

## 14. MVP Boundary Check

未新增路由、实体、依赖、权限、远端能力或数据迁移；仅改变已有规则的决策时机，保持在 V1。

## 15. Launch-Blocking TODOs

none

## 16. Requirement Logic Readiness

`REQUIREMENT LOGIC READY`：动作、状态、边界、owner、页面职责和恢复路径完整，可直接实现。
