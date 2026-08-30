# 单场地、单双打与一局比分需求影响分析

document_state: accepted
decision_date: 2026-08-30
product_flow_mode: feature-impact-analysis

## 1. Requested Change

- 新建与复制球局固定一个 `Court`。
- 创建球局时必须选择 `MatchFormat.singles` 或 `MatchFormat.doubles`。
- `quick_11` 与 `standard_21` 都只记录一局最终比分。
- 单打以个人为候场与轮转单位；双打继续以固定双人组为单位。

## 2. Feature Classification

- Runtime Required: `MatchFormat`、单场地、新的一局比分校验、两套候场与轮转单位。
- Runtime Support: 旧多场地与旧多局比分数据兼容读取和收尾。
- Expansion: 混双、单场临时切换赛制、多场地、逐球计分、三局两胜。

## 3. Impacted Logic Chain

```text
创建球局 -> 选择 singles / doubles -> 自动建立唯一场地
singles -> 添加玩家 -> 个人候场 -> 两人上场 -> 一局比分 -> 个人轮转
doubles -> 添加玩家 -> 固定组队 -> 两组上场 -> 一局比分 -> 双人组轮转
处理全部未决比赛 -> 完成球局 -> 总结
```

## 4. Runtime Action Changes

### Runtime Action: create_session

- action_id: create_session
- actor: LocalOrganizer
- initiation: 球局列表新建
- source state: none
- target entity: PlaySession
- preconditions: 本地存储可写
- input fields: title, matchFormat, scorePreset, defaultRotationMode
- boundary checks: title 非空；枚举有效
- state transition: none -> draft
- success result: 创建含唯一可用场地的球局
- failure result: 不创建半成品
- recovery path: 修正输入或重试
- owner: PlaySession
- required test assertion: 创建结果始终只有一个 Court

### Runtime Action: update_session_setup

- action_id: update_session_setup
- actor: LocalOrganizer
- initiation: draft 设置
- source state: draft
- target entity: PlaySession
- preconditions: 球局未启动
- input fields: title, matchFormat, scorePreset, defaultRotationMode
- boundary checks: 切换赛制时清理不兼容的候场/组队准备状态
- state transition: draft -> draft
- success result: 新赛制与准备状态一致
- failure result: 保留原设置和准备状态
- recovery path: 取消或重新确认
- owner: PlaySession
- required test assertion: active 不可切换；draft 切换不留下跨赛制组队

### Runtime Action: start_session

- action_id: start_session
- actor: LocalOrganizer
- initiation: 准备页主行动
- source state: draft
- target entity: PlaySession
- preconditions: singles 至少两名 waiting 玩家；doubles 至少两个 waiting 组；唯一场地可用
- input fields: sessionId
- boundary checks: 赛制与候场单位一致
- state transition: draft -> active
- success result: 冻结赛制与比分规则
- failure result: 保持 draft
- recovery path: 补人或完成组队
- owner: PlaySession
- required test assertion: singles 2 人可启动；doubles 少于 2 组不可启动

### Runtime Action: assign_next

- action_id: assign_next
- actor: LocalOrganizer
- initiation: 空闲球场主行动
- source state: active + Court.available
- target entity: SessionMatch
- preconditions: singles 有 2 名 waiting；doubles 有 2 个 waiting group
- input fields: courtNumber=1
- boundary checks: 候场单位唯一且未被占用
- state transition: waiting units -> assigned; Court.available -> ready
- success result: 创建与赛制人数一致的 ready match
- failure result: 不创建残缺比赛
- recovery path: 等待更多候场单位
- owner: PlaySession
- required test assertion: singles 创建 2 人场；doubles 创建 4 人场

### Runtime Action: finish_match

- action_id: finish_match
- actor: LocalOrganizer
- initiation: 比赛中 Court
- source state: Match.inProgress
- target entity: MatchResult
- preconditions: 当前 Match 与 Court 一致
- input fields: winnerOnly 或单个 GameScore
- boundary checks: quick_11 恰好一局到 11；standard_21 恰好一局并遵守加分与 30 分封顶
- state transition: inProgress -> resultRecorded
- success result: 候场单位进入 awaitingRotation
- failure result: 比赛保持 inProgress
- recovery path: 修正比分或只选胜方
- owner: PlaySession
- required test assertion: 21 分多局输入被拒绝，合法单局被接受

### Runtime Action: resolve_winner_stays

- action_id: resolve_winner_stays
- actor: LocalOrganizer
- initiation: resultRecorded 后
- source state: awaitingRotation
- target entity: Court 与候场队列
- preconditions: 已产生唯一胜方
- input fields: matchId
- boundary checks: singles 以玩家为单位；doubles 以组为单位；刚下场单位不能立即补回
- state transition: 胜方 staying；败方队尾；旧 waiting 队首补位
- success result: 有对手则 ready，无对手则 waitingOpponent
- failure result: 原子保持未轮转
- recovery path: 重试或选择全部下场
- owner: PlaySession
- required test assertion: 两种赛制均不立即补回败方

### Runtime Action: resolve_all_rotate

- action_id: resolve_all_rotate
- actor: LocalOrganizer
- initiation: resultRecorded 后
- source state: awaitingRotation
- target entity: Court 与候场队列
- preconditions: Match 结果已记录
- input fields: matchId
- boundary checks: 当前参赛单位先排除于本轮补位候选
- state transition: 当前单位进队尾；旧 waiting 队首进入下一场
- success result: 候场足够则 ready，否则 Court.available
- failure result: 原子保持未轮转
- recovery path: 重试
- owner: PlaySession
- required test assertion: singles 取两名旧 waiting；doubles 取两个旧 waiting group

## 5. State Transition Changes

Entity: PlaySession
- from: draft
  event/action: update_session_setup(matchFormat changed)
  guard condition: session 尚未 active
  to: draft
  actor: LocalOrganizer
  side effects: 清理格式专属准备状态并重建候场单位
  reversible: yes
- from: active
  event/action: update matchFormat
  guard condition: none
  to: active
  actor: LocalOrganizer
  side effects: 阻止修改
  reversible: not_applicable

Entity: SessionPlayer
- singles: waiting -> assigned -> playing -> awaitingRotation -> waiting/staying
- doubles: ungrouped -> grouped -> assigned -> playing -> awaitingRotation -> grouped/staying

Entity: Court
- 仅保留一个运行实例；状态机继续为 available -> ready -> inPlay -> awaitingRotation -> ready/available/waitingOpponent。

blocked operations:
- active/completed 禁止修改 matchFormat。
- 新模型禁止新增第二块场地。
- singles 禁止组队与组分配。
- doubles 禁止个人直接分配。

terminal states: PlaySession.completed / deleted。

## 6. Boundary Check Changes

Boundary Check:
- action_id: update_session_setup
- check_type: state
- condition: 仅 draft 可以切换 matchFormat
- block result: 原状态不变
- feedback: 球局开始后不能切换单双打
- recovery path: 新建或复制为另一赛制
- verification assertion: active 修改抛出 state violation

Boundary Check:
- action_id: assign_next
- check_type: capacity
- condition: singles >=2 waiting players；doubles >=2 waiting groups
- block result: Court 保持 available
- feedback: 明确还差多少人或组
- recovery path: 加人、恢复候场或组队
- verification assertion: 不生成残缺 Match

Boundary Check:
- action_id: finish_match
- check_type: input
- condition: gameScores 恰好包含一个合法 GameScore
- block result: Match 保持 inProgress
- feedback: 显示单局比分规则
- recovery path: 修正双方分数
- verification assertion: standard21 多局结果被拒绝

## 7. Data Ownership Changes

Data Ownership:
- owner entity: PlaySession
- owned data: matchFormat、唯一 Court、玩家、双人组、候场顺序、比赛和轮转
- allowed mutations: 本文 Runtime Action
- derived state: readiness、waiting units、下一动作、统计
- forbidden owner leakage: 页面不得自行把 singles 玩家包装成伪双人组
- required test assertion: snapshot restore 后赛制与候场单位一致

Data Ownership:
- owner entity: SessionMatch
- owned data: 两个参赛 side、单局结果、完成顺序、轮转方式
- allowed mutations: start / finish / correct / complete rotation
- derived state: 胜方与得失分
- forbidden owner leakage: UI 不得决定胜方或改变 side 人数
- required test assertion: side 人数与 matchFormat 一致

## 8. Permission Changes

- 角色仍只有 LocalOrganizer。
- 不新增账号、裁判或远端权限。
- 赛制修改权限受 PlaySession.state 约束。

## 9. Lifecycle Changes

- beginning: 创建时选赛制并自动创建唯一 Court。
- active period: 赛制冻结；按个人或组推进候场、比赛和轮转。
- terminal: 清理未决比赛后完成球局并生成总结。
- legacy aftermath: 旧多场地和旧多局球局可继续读取、完成和查看；复制时转为新单场地规则。

## 10. Surface Responsibility Changes

SessionSetup:
- entry source: 球局列表或 draft 设置
- responsibility: title、matchFormat、scorePreset、rotationMode
- exit/back: 取消不保存
- empty: title 校验
- readonly: active 不进入可编辑设置
- error: 保留输入并说明原因
- destructive confirmation: 切换赛制且已有准备状态时确认清理

SessionRoster:
- singles 显示个人候场 readiness，不显示组队动作。
- doubles 显示玩家、固定组与 readiness。
- 不显示场地增删。

LiveSession:
- Court 按 singles 显示 2 人，按 doubles 显示 4 人。
- 上场顺序按赛制显示个人或双人组。
- 结果录入只提供一局比分。

## 11. Entity Changes

- 新增 `MatchFormat.singles / doubles`。
- Match side 的玩家数由赛制决定：singles=1，doubles=2。
- Court 增加可选 stayingPlayer 身份，以支持单打胜方留场。
- PairingGroup 仅存在于 doubles。

## 12. New Failure / Recovery Paths

- 赛制切换时存在组队：确认后解散组并重建候场；取消则不修改。
- singles 候场少于 2 人：保持空闲并引导加人/恢复。
- doubles 候场少于 2 组：保持空闲并引导组队。
- 旧多局比分：兼容读取，不允许新录入同类结果。
- 旧多场地 active：保留全部 Court 直到完成；新建/复制回到唯一 Court。

## 13. Assumptions and Unknowns

Assumption:
- assumption: singles 与 doubles 都支持 quick_11 和 standard_21
- why low risk: 比分规则与参赛人数无冲突
- affected logic: setup / score validation
- validation needed: tests

Assumption:
- assumption: 旧数据采用非破坏兼容，不自动删除额外 Court 或多局比分
- why low risk: 避免本地数据丢失
- affected logic: persistence restore / duplicate
- validation needed: migration tests

Unknown: none blocking。

## 14. MVP Boundary Check

- 新方向替代“多场地、仅双打、21 分三局两胜”。
- 混双、逐球计分、临时跨赛制、重新开放多场地仍是 Non Goals。
- 结论：未产生 MVP explosion。

## 15. Launch-Blocking TODOs

- required item: matchFormat 非破坏持久化
- why runtime-required: App 重启后必须恢复正确候场单位
- current missing condition: schema v4 无 matchFormat / singles staying player
- blocked runtime flow: singles resume
- owner or required dependency: PlaySession snapshot + Drift store
- unblock condition: migration and round-trip tests pass
- temporary workaround allowed: no

## 16. Requirement Logic Readiness

`REQUIREMENT LOGIC READY`

- 主链路闭合。
- 受影响 action、state、boundary、owner、surface 与 recovery 已明确。
- 不存在 blocking Unknown。

