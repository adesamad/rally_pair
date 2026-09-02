# 现场球局单工作台与连续推进决策

document_state: accepted
decision_date: 2026-09-02

## Decision

羽搭 V1 的 active 球局采用单一 `CourtWorkspace`，围绕“当前比赛 -> 结束本场 -> 准备下一场”连续推进。

- 不再使用“现场 / 球友 / 记录”三个同级底部导航。
- `CourtWorkspace` 默认展示当前比赛、候场摘要和唯一下一动作。
- 球友与组队、候场顺序、比赛记录保留为上下文工具。
- 轮换方式在创建或调整 draft 球局时直接选择，开局后冻结。
- 新单场地流程不展示场地选择、批量排场、场地数量或重复的“1 号场”身份。
- 旧多场地 active 数据恢复后仍保留逐场地操作能力。

## Locked Interaction Semantics

### Start First Match

```text
PlaySession.draft
-> LocalOrganizer 点击“开始第一场”
-> 校验 singles 至少 2 名 waiting / doubles 至少 2 个 waiting group
-> PlaySession.active
-> 按队首分配唯一 Court
-> Match.inProgress + Court.inPlay
```

启动、分配和首场开赛必须作为一个原子用户意图，不再让用户进入空球场后重复确认。

### Finish And Rotate

```text
Match.inProgress
-> 在同一结算表面选择胜方或一局比分
-> PlaySession 自动读取 defaultRotationMode
-> 原子记录结果、完成旧 Match、更新候场并创建下一场 ready Match
```

轮换方式是整场球局规则。结算表面不得再次要求选择，也不提供单场覆盖。

下一场仍保留“开始比赛”确认，因为 `ready` 只代表人员已经排好，不代表现场已经真实开打。

### End Session

组织者确认结束后，PlaySession 负责统一收尾：

- `ready / inProgress` Match 取消且不计统计。
- `resultRecorded` Match 保留结果并完成轮转记录。
- `waitingOpponent` Court 释放留场单位。
- 全部 Court 回到 available 后进入 PlaySession.completed 并生成总结。

## Runtime Action Matrix

### start_first_match

- actor: LocalOrganizer
- source state: PlaySession.draft
- preconditions: 唯一场地可用且候场单位不少于 2
- state transition: draft -> active；waiting -> playing；Court.available -> inPlay
- failure result: 保持 draft，不创建部分 Match
- owner: PlaySession
- required test assertion: 一次动作后首场必须为 inProgress

### finish_and_rotate

- actor: LocalOrganizer
- source state: Match.inProgress
- preconditions: 结果合法且 PlaySession.defaultRotationMode 受支持
- state transition: inProgress -> completed；下一场 none -> ready 或 Court.waitingOpponent/available
- failure result: 原比赛保持 inProgress
- owner: PlaySession
- required test assertion: UI 只提交 MatchResult，系统自动使用 defaultRotationMode

### end_session

- actor: LocalOrganizer
- source state: PlaySession.active
- preconditions: 用户确认
- state transition: unfinished -> canceled / recorded -> completed / staying -> waiting；PlaySession.active -> completed
- failure result: 原子保持 active
- owner: PlaySession
- required test assertion: 进行中比赛可以通过结束球局统一取消并完成

## Consequences

- LiveSessionPage 是单一 composition root，不再用底部导航切换业务实体。
- 高频动作由当前 runtime state 决定，避免两个并列主按钮执行同一意图。
- 辅助管理能力可使用 bottom sheet，但不得复制 PlaySession 状态或自行决定轮转结果。
- 创建页必须直接展示轮换方式和整场生效范围，不得放入默认折叠的高级设置。
- 本决策不改变单双打、固定双人组、比分校验、轮转算法、历史纠错或持久化 schema。

## Source Of Truth

产品范围与业务状态仍以 [羽搭 / RallyPair 产品方向基线](../knowledge/product/badminton-session-organizer.md) 为准；本文冻结 active 球局的交互骨架和组合动作语义。
