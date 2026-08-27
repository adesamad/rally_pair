# 羽搭运行模型替换 Execution Spec

exec_spec_state: completed
mode: create-exec-spec + closure-update
updated_at: 2026-08-27

## 1. Execution Scope

将已 accepted 的持续双人组、组候场队列、具体场地、比分和双模式轮转产品基线转换为 7 个可独立验收的 Flutter vertical slice。目标项目为当前仓库；下游 skill 为 `code-flow`，Court UI phase 同时消费 `app-design / flutter-ui-production` 约束。

禁止联网、登录、单打、逐球计分、新路由、新状态管理、新第三方 UI/图标/动画依赖和未来 action 预建。保留五个现场导航、`PlaySession` 聚合根和 `PlaySessionStore.update` 事务入口。

## 2. Source Extraction

Source Trace:
- source file: `docs/knowledge/product/badminton-session-organizer.md`
- source section: `7. Runtime Action Matrix`
- source quote or line anchor: lines 235–760，31 个 action 的 actor、guard、transition、failure、recovery 和 test assertion

Source Trace:
- source file: `docs/knowledge/product/badminton-session-organizer.md`
- source section: `8. State Machine`、`9. Boundary Check Matrix`、`10. Data Ownership Matrix`
- source quote or line anchor: lines 764–1276，PlaySession、SessionPlayer、PairingGroup、Match、Court 与跨实体约束

Source Trace:
- source file: `docs/knowledge/product/badminton-session-organizer.md`
- source section: `12. Lifecycle`、`13. Failure / Recovery Matrix`、`14. Runtime Surface Responsibilities`
- source quote or line anchor: lines 1283–1422，恢复、原子保存、页面入口与错误处理

Source Trace:
- source file: `docs/decisions/group-court-rotation-runtime-direction.md`
- source section: `Locked Product Semantics`、`Superseded Direction`
- source quote or line anchor: 持续组、双排序、双轮转、具象 Court UI 与旧模型废止

提取结果：

- runtime actions: 31
- entity states: 5 个 owner 状态机
- persistence owner: `PlaySessionSnapshot` + `FdPlaySessionStore` + Drift transaction
- surfaces: SessionLibrary、SessionSetup、GroupingWorkspace、RotationWorkspace、CourtWorkspace、MatchResultEntry、RotationDecision、SessionSummary
- launch blockers: `replace_legacy_runtime_model`、`implement_court_object_renderer`

## 3. Missing For Execution

`MISSING_FOR_EXECUTION`: none。

非阻塞实现决策：schema v3 升级 v4 时保留历史比赛；旧 active 的 ready/inProgress Team 转为有效 PairingGroup；无法可靠推断搭档的旧 waiting 玩家转为 ungrouped，不删除球局。

## 4. Runtime Action Mapping

所有 mapping 的 actor 均为 `LocalOrganizer`，owner method 位于 `PlaySession`，UI 通过 `PlaySessionStore.update` 触发，repository 通过单事务保存 snapshot。表中“失败”均要求不修改旧 snapshot 并显示 `RuleViolation` 的可恢复文案。

| action_id | phase | current | source | surface / item entry | entity | required implementation / transition / persistence | failure / recovery / test | forbidden simplification |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| create_session | P1 | yes | baseline:235 | SessionLibrary 新建按钮 | PlaySession | create draft；保存 setup、空 players/groups/courts/matches | 空标题拒绝；修正输入；创建测试 | 用内存临时 session 冒充保存 |
| update_session_setup | P1 | yes | baseline:252 | 指定 draft 设置页 | PlaySession | draft→draft；更新 title/score/defaultRotation | active 拒绝；保留旧设置 | 允许 active 改比分规则 |
| add_session_player | P1 | yes | baseline:286 | 添加玩家按钮 | SessionPlayer | none→ungrouped；事务保存 | 重名/第65人拒绝；指定输入测试 | 自动加入某组 |
| batch_add_session_players | P1 | yes | baseline:303 | 批量添加 Dialog | SessionPlayer collection | 原子加入唯一有效姓名 | 容量失败整批回滚；重名报告 | 部分超量写入 |
| add_court | P1 | yes | baseline:405 | 场地准备区添加按钮 | Court | none→available，保存唯一 displayName | 重名/第9块拒绝 | 只改 setup.courtCount |
| remove_court | P4 | yes | baseline:422 | 指定 available 场地菜单 | Court | available→deleted，保留历史 match snapshot | 占用场地拒绝；非首场地测试 | 删除 current/first court |
| generate_random_groups | P2 | yes | baseline:439 | GroupingWorkspace 随机组队 | PairingGroup | 两两创建 waiting；玩家 ungrouped→grouped | 奇数留一人；固定种子测试 | 每轮临时 Team |
| create_manual_group | P2 | yes | baseline:456 | 指定两名玩家确认 | PairingGroup | none→waiting，组队尾 | 重复成员拒绝；指定非首玩家测试 | 默认选择前两人 |
| update_waiting_group | P2 | yes | baseline:473 | 指定 waiting 组换人 | PairingGroup | 保持 groupId/queueOrder，替换成员 | 锁定组拒绝；非首组测试 | 修改 Match 快照 |
| dissolve_waiting_group | P2 | yes | baseline:490 | 指定 waiting 组解散 | PairingGroup | waiting→dissolved；成员→ungrouped | 非 waiting 拒绝；确认测试 | 解散当前第一组 |
| start_session | P2 | yes | baseline:269 | 准备页开始按钮 | PlaySession | draft→active；冻结设置 | 少于两组/无场地拒绝 | 只按四名玩家判断 |
| update_session_player | P3 | yes | baseline:320 | 指定玩家编辑 | SessionPlayer | 当前可编辑状态自转换 | 场上组锁定；非首玩家测试 | 通过 index 改名 |
| set_player_resting | P3 | yes | baseline:337 | 指定 ungrouped 玩家休息 | SessionPlayer | ungrouped→resting | grouped 拒绝 | 自动解散组 |
| restore_player_eligible | P3 | yes | baseline:354 | 指定 resting/left 玩家恢复 | SessionPlayer | resting/left→ungrouped | 不自动成组；指定项测试 | 直接回 waiting group |
| set_player_left | P3 | yes | baseline:371 | 指定玩家离场 | SessionPlayer | ungrouped/resting→left | 有效组成员拒绝 | 静默解散组 |
| remove_session_player | P3 | yes | baseline:388 | 指定玩家删除确认 | SessionPlayer | 无历史、未成组→deleted | 历史引用拒绝；非首项测试 | 删除 first player |
| randomize_group_queue | P4 | yes | baseline:507 | RotationWorkspace 随机顺序 | PairingGroup queue | 仅 waiting 重写 queueOrder | 少于两组不变；固定种子测试 | 移动场上组 |
| reorder_waiting_group | P4 | yes | baseline:524 | 指定 waiting 组上移/下移 | PairingGroup queue | waiting→waiting 新稳定顺序 | 越界回滚；非首组测试 | reorderFirstGroup |
| assign_next_groups_to_court | P4 | yes | baseline:541 | 指定 available Court 按队首分配 | Court/Match/Group | 两组 waiting→assigned；Court→ready；Match.ready | 少一组不创建；多场地唯一测试 | 创建残缺 Match |
| assign_specific_groups_to_court | P4 | yes | baseline:558 | 指定 Court 选择两组 | Court/Match/Group | 指定 waiting 组创建 Match.ready | 冲突全部回滚；非首场地/组测试 | 默认第一块场 |
| start_match | P5 | yes | baseline:575 | 指定具象 Court 开始比赛 | Match/Court/Group | ready→inProgress；Court inPlay；组 playing | 引用不一致回滚 | Widget 自己改状态 |
| record_match_result | P5 | yes | baseline:592 | 指定 Court 结果 Dialog | Match/Court/Group | inProgress→resultRecorded；Court/组 awaitingRotation | 无效比分保持 inPlay；比分测试 | 录分后直接释放场地 |
| cancel_match | P5 | yes | baseline:677 | 指定 ready/inProgress Court 取消 | Match/Court/Group | Match→canceled；Court available；组回队首 | completed 拒绝；不计统计 | 取消 first match |
| resolve_rotation_winner_stays | P6 | yes | baseline:609 | 指定 awaitingRotation Court 决策 | PlaySession aggregate | 原场 completed；胜组 assigned/staying；败组队尾；可建下一场 | 刚下场组排除；足/不足 fixture | finishMatch 四人回队 |
| resolve_rotation_all_rotate | P6 | yes | baseline:626 | 指定 awaitingRotation Court 决策 | PlaySession aggregate | 两组队尾；既有 waiting 两组可进 Match.ready | 候场不足 Court.available | 让刚下场组即时补位 |
| fill_staying_court | P6 | yes | baseline:643 | 指定 waitingOpponent Court 补位 | Court/Match/Group | staying+waiting→assigned；Court ready | 无 waiting 保持原状 | 默认拿刚下场组 |
| release_staying_court | P6 | yes | baseline:660 | 指定 waitingOpponent Court 释放 | Court/Group | staying→waiting 队尾；Court available | 未确认不变 | 直接丢失 staying 组 |
| correct_completed_match | P7 | yes | baseline:694 | 指定历史 Match 修正 | Match | completed 自转换；重算 stats | 无效结果保留旧值；后续轮转不回滚 | 修改后续 Match |
| complete_session | P7 | yes | baseline:711 | 现场结束球局确认 | PlaySession | active→completed；有效 player/group archived | 未决 Court 阻塞 | 强制清空场地 |
| duplicate_session_setup | P7 | yes | baseline:728 | 指定历史球局再次组织 | PlaySession | 新 draft；复制设置/场地名/玩家名 | 不复制组、比赛、队列、统计 | 复制 active owner 状态 |
| delete_session | P7 | yes | baseline:745 | 指定球局二次确认 | PlaySession | current→deleted；事务删除 child | 失败保留全部 child | 部分表删除 |

## 5. File-Level Responsibility Mapping

| layer | file or directory | owns | cannot own | allowed current symbols (P1) | forbidden non-current symbols | shortcuts |
| --- | --- | --- | --- | --- | --- | --- |
| domain | `lib/play_session/models.dart` | P1 所需 setup/player/court/group基础状态 | persistence/UI | `RotationMode`、`PairingGroup` 基础值、P1 enum/field | P2–P7 action inputs、轮转实现 | 临时 Team 继续充当有效组 |
| runtime | `lib/play_session/session.dart` | 聚合状态与 action guard | UI copy/SQL | `create/update setup/add player/batch/addCourt` 及 snapshot | P2–P7 methods/stubs | first/current/default item |
| data | `lib/play_session/snapshot.dart` | P1 owner 快照 | 业务决策 | groups、nextGroupId、动态 courts | future action DTO catalog | 内存 list 代替持久化 |
| data | `lib/rally_pair_helper/fd_rally_pair_db/` | schema v4、旧行兼容、事务映射 | 组队/轮转选择 | group table、P1 fields、migration/read/write | P2–P7 repository action methods | 清库升级 |
| ui | `lib/session_library/`、`lib/session_flow/session_roster_page.dart` | P1 用户入口和状态呈现 | 业务 owner | 默认轮转、动态场地准备、add/batch/start disabled copy | P2 组队 action UI | Widget 自行维护业务集合 |
| test | `test/play_session/`、`test/rally_pair_helper/fd_rally_pair_db/`、`test/widget_test.dart` | P1 行为与兼容证据 | production state | P1 action/state/schema/widget tests | future test skeleton | 只测首项 |

`allowed files are containers, not allowed features`: yes。即使文件允许修改，也只能创建当前 phase 的列名、类型、方法、入口和测试。

## 6. State Transition Contract

| entity | allowed states | current phase transitions | later transitions | guards / implementation locations |
| --- | --- | --- | --- | --- |
| PlaySession | draft, active, completed, deleted | none→draft；draft自更新 | P2 start；P7 complete/delete | model `session.dart`；store restore test；surface disabled state |
| SessionPlayer | ungrouped, grouped, resting, left, archived | none→ungrouped | P2 grouped；P3 availability；P7 archived | action guard in aggregate；指定 player test |
| PairingGroup | waiting, assigned, playing, awaitingRotation, staying, dissolved, archived | P1 仅可被 snapshot 表达，不提供创建 action | P2–P7 正式 transitions | group uniqueness restore guard；UI 不可直接写 |
| SessionMatch | ready, inProgress, resultRecorded, completed, canceled | P1 无 action | P4–P7 | Match/Court/Group 引用一致性 |
| Court | available, ready, inPlay, awaitingRotation, waitingOpponent | none→available | P4–P7 | displayName 唯一、最多8块、当前引用一致 |

禁止 transition：draft 进入比赛；completed 继续组队/分配；任一组跨场地重复；record result 直接 completed；waitingOpponent 同时存在两组。

## 7. Persistence Contract

Persistence Contract:
- storage owner: `FdPlaySessionStore` / `FdRallyPairDatabase`
- create: 单事务写 PlaySession、players、groups、courts、matches、games
- update: `PlaySessionStore.update` 内 load → action → snapshot → 全量 child 原子替换
- delete: 先删 child 后删 root，全部位于 transaction
- read: 按 sessionId 读取全部 owner 并 `PlaySession.restore` 校验
- recover: schema v3 行兼容为 v4；旧当前 Team 转组，旧 waiting 转 ungrouped，历史 Match 快照保留
- failure behavior: 抛稳定错误并回滚 transaction，不保存部分状态
- temporary storage:
  - allowed: no
  - scope: no
  - required interface: not_applicable

## 8. Surface Contract

| surface | must display | must trigger | must block / error | must not |
| --- | --- | --- | --- | --- |
| SessionSetup/Roster | title、score、default rotation、玩家、具体场地 | create/update/add/batch/addCourt，P2 start | 重名、容量、启动条件 | 用 courtCount 代替全部场地对象 |
| GroupingWorkspace | ungrouped 玩家、waiting 组 | P2 random/manual/update/dissolve | 锁定组编辑 | 临时分四人 |
| RotationWorkspace | waitingGroups 稳定顺序 | P4 randomize/reorder | 移动非 waiting 组 | 展示个人公平轮转 |
| CourtWorkspace | 具象场地、两组四人、比分、状态、下一动作 | P4 assign、P5 match、P6 rotation | 跨场地冲突、无效比分 | 普通 A/B 卡片 |
| MatchResultEntry | winnerOnly/gameScores | record/correct | 无唯一胜方或无效局分 | 逐球计分 |
| SessionSummary | 完成比赛和派生统计 | correct/duplicate/delete | 现场动作只读 | 反写轮转历史 |

## 9. Boundary & Failure Contract

| boundary_id | action_id | guard owner | failure result | recovery | tests |
| --- | --- | --- | --- | --- | --- |
| session_input/start | create/update/start | PlaySession | draft 不变 | 修正设置/补组/加场地 | 空标题、无场地、少两组 |
| player_identity | add/batch/update/remove | PlaySession | player map 不变 | 改名/减少名单 | 重名、容量、非首项 |
| group_membership/edit | generate/create/update/dissolve | PlaySession | group/player/queue 不变 | 选择其他 player/group | 唯一成员、锁定组 |
| court_capacity | add/remove | PlaySession | courts 不变 | 改名/处理占用 | 第9块、非首占用场地 |
| assignment | assign/fill | PlaySession | 不创建 Match | 补组/选其他组 | 一组不足、多场地唯一 |
| result | record/correct | Match + ScoreRules | Match/Court 不变 | 修正输入 | 21:20/31:29 invalid |
| rotation | resolve/fill/release | PlaySession | 全部 owner 回滚 | 保持 awaiting 可重试 | exclusion/atomicity |
| destructive | remove/cancel/complete/delete | PlaySession | 未确认不变 | 取消或处理冲突 | 指定项+事务失败 |

## 10. Phase Breakdown

### Phase P1

- phase id: P1
- phase name: session preparation
- phase type: vertical-slice
- user-visible outcome: 用户能创建球局、添加玩家、添加具名场地，并看到后续启动条件基于组和场地而不是四名候场玩家。
- UI/runtime entry: SessionLibrary → SessionSetup/Roster
- current phase action ids: create_session, update_session_setup, add_session_player, batch_add_session_players, add_court
- files: `lib/play_session/`、`lib/rally_pair_helper/fd_rally_pair_db/`、`lib/session_library/`、`lib/session_flow/session_roster_page.dart`、对应 tests
- allowed files are containers, not allowed features: yes
- allowed current symbols: `RotationMode`、P1 所需新状态、`PairingGroup` snapshot 基础、`PlaySession.addCourt`、P1 setup fields、schema v4 group/court fields、P1 UI entries/tests
- forbidden non-current symbols: P2 group action methods/entries，P4 assignment，P5 resultRecorded action，P6 rotation methods/UI，P7 closure additions
- action chain: UI → store.update → PlaySession P1 action → snapshot → Drift transaction → P1 tests
- acceptance: 新球局保存玩家和具名场地；重启一致；旧 v3 session 可加载且历史 Match 数不变。
- validation commands: targeted domain/store/widget tests；`fvm flutter analyze`
- do not: 不实现组队按钮、场地分配或轮转。
- forbidden shortcuts: first/current/default item；清库迁移；Widget state persistence
- downstream skill: code-flow

### Phase P2

- phase id/name/type: P2 / group formation and start / vertical-slice
- user-visible outcome: 用户可随机或手动形成持续组、编辑/解散指定等待组并启动球局。
- UI/runtime entry: Roster + GroupingWorkspace
- current phase action ids: generate_random_groups, create_manual_group, update_waiting_group, dissolve_waiting_group, start_session
- files: `lib/play_session/`、Grouping/Roster UI、tests
- allowed files are containers, not allowed features: yes
- allowed current symbols: 五个 P2 methods、group dialogs/rows、P2 tests
- forbidden non-current symbols: P3 availability、P4 queue/assignment、P5–P7
- action chain: UI → store.update → group action → snapshot → store → specified-group tests
- acceptance: 五人随机两组余一人；手动指定组；非首组可换人/解散；两组+场地可启动。
- validation commands: targeted session/widget tests
- do not/shortcuts: 不临时 Team；不自动拆已有组；不预建 queue/court action
- downstream skill: code-flow

### Phase P3

- phase id/name/type: P3 / live player availability / vertical-slice
- user-visible outcome: 用户能对指定未成组玩家改名、休息、恢复、离场或删除，组内/场上玩家被正确锁定。
- UI/runtime entry: WaitingWorkspace 指定 player row
- current phase action ids: update_session_player, set_player_resting, restore_player_eligible, set_player_left, remove_session_player
- files: domain、Waiting/Roster UI、tests
- allowed files are containers, not allowed features: yes
- allowed current symbols: 五个 P3 methods、item actions/copy/tests
- forbidden non-current symbols: queue/assignment/result/rotation/closure
- action chain: player row → store.update → guard → snapshot → specified-player test
- acceptance: 非首 player 动作正确；grouped/playing 状态全部拒绝。
- validation commands: targeted domain/widget tests
- do not/shortcuts: 不自动解散组；不按 index 操作
- downstream skill: code-flow

### Phase P4

- phase id/name/type: P4 / group queue and court assignment / vertical-slice
- user-visible outcome: 用户可随机/手动排组，为指定具名场地自动或手动安排两组，并移除指定空闲场地。
- UI/runtime entry: RotationWorkspace + available Court
- current phase action ids: remove_court, randomize_group_queue, reorder_waiting_group, assign_next_groups_to_court, assign_specific_groups_to_court
- files: domain、Rotation/Court UI、store snapshot、tests
- allowed files are containers, not allowed features: yes
- allowed current symbols: 五个 P4 methods、queue rows、assignment sheet、tests
- forbidden non-current symbols: start/result/rotation decision/closure
- action chain: queue/court item → aggregate → Match.ready snapshot → store → multi-court tests
- acceptance: 指定非首组/场地有效；组不跨场重复；不足两组不创建 Match。
- validation commands: targeted domain/widget/store tests
- do not/shortcuts: 不选择默认第一块场；不创建残缺比赛
- downstream skill: code-flow

### Phase P5

- phase id/name/type: P5 / concrete court match and score / vertical-slice
- user-visible outcome: 具象化场地显示两侧四人，用户可开赛、取消或录入结果，录分后明确等待上下场决策。
- UI/runtime entry: CourtWorkspace + MatchResultEntry
- current phase action ids: start_match, record_match_result, cancel_match
- files: domain、Court/Result UI、score tests、widget tests
- allowed files are containers, not allowed features: yes
- allowed current symbols: P5 methods、court painter/renderer、result dialog、five court state rendering基础、tests
- forbidden non-current symbols: P6 rotation mutations、P7 closure
- action chain: concrete Court action → aggregate → Match/Court/Group transition → store → widget/domain test
- acceptance: 标准球场两侧四人；无效比分仍 inPlay；合法比分进入 awaitingRotation；取消不计统计。
- validation commands: score/session/widget tests；narrow-screen test
- do not/shortcuts: 不退化 A/B 卡；不逐球计分；不新增依赖
- downstream skill: code-flow + app-design/flutter-ui-production

### Phase P6

- phase id/name/type: P6 / post-match rotation / vertical-slice
- user-visible outcome: 用户在指定场地选择胜方留场或两组下场，并能补位或释放留场场地。
- UI/runtime entry: awaitingRotation/waitingOpponent Court + RotationDecision
- current phase action ids: resolve_rotation_winner_stays, resolve_rotation_all_rotate, fill_staying_court, release_staying_court
- files: domain、Court/Rotation UI、store、tests
- allowed files are containers, not allowed features: yes
- allowed current symbols: 四个 P6 methods、rotation sheet/buttons、P6 fixtures/tests
- forbidden non-current symbols: correct/complete/duplicate/delete 新入口
- action chain: Court decision → aggregate atomic rotation → snapshot/store → next Court state → tests
- acceptance: 足/不足候场闭环；刚下场组不即时重赛；原子失败可重试。
- validation commands: session/store/widget tests
- do not/shortcuts: 不在 UI 拼队列；不自动固定一种轮转
- downstream skill: code-flow + app-design/flutter-ui-production

### Phase P7

- phase id/name/type: P7 / history and session closure / vertical-slice
- user-visible outcome: 用户可修正指定历史结果、结束无未决状态球局、复制设置或删除指定球局。
- UI/runtime entry: Results/SessionSummary/SessionLibrary item actions
- current phase action ids: correct_completed_match, complete_session, duplicate_session_setup, delete_session
- files: domain、Results/Library UI、store、tests
- allowed files are containers, not allowed features: yes
- allowed current symbols: 四个 P7 methods/entries/tests、closure state update
- forbidden non-current symbols: V1 外扩展、导出/分享/联网
- action chain: specified history/session item → aggregate → transaction → summary/library → tests
- acceptance: 未决场地阻塞结束；修正只重算统计；副本无组/比赛；删除无孤儿数据。
- validation commands: full analyze/test/docs check
- do not/shortcuts: 不回滚历史轮转；不删除默认/首个 session
- downstream skill: code-flow

## 11. Phase Validity Gate

P1–P7 均满足：user-visible outcome=pass；UI/runtime entry=pass；action chain=pass；非横向技术层=pass；每 phase 3–5 actions=pass；future abstraction absent=pass；item-level entry/test=pass；forbidden shortcuts named=pass；可单独 handoff=pass。

## 12. Current Phase Minimality Gate

Current Phase Minimality Gate:
- phase id: P1
- current phase action ids listed: pass
- allowed files declared as containers only: pass
- allowed current symbols listed: pass
- forbidden non-current symbols listed: pass
- non-current action enum/catalog/input/result absent from handoff: pass
- non-current repository/store/controller methods absent from handoff: pass
- non-current UI entries/placeholders absent from handoff: pass
- non-current test skeletons absent from handoff: pass
- future-only abstraction absent: pass
- template-derived child data limited to current phase need: pass

## 13. Execution Progress State

Execution Progress State:
- current phase: complete
- next phase: none
- phase statuses: P1–P7=closed
- action statuses: 31 个 action=closed
- blockers: none
- last closure: P7 history and session closure
- last validation: `fvm flutter analyze` 0 issues；`fvm flutter test` 全量通过；schema v3 fixture 通过；docs-keeper check=PASS

## 14. Closure Contract

Phase Closure:
- phase id: `<current>`
- status: 只有全部 action `closed` 后才能写 closed
- implemented actions: action_id 列表
- code evidence: action_id + file + symbol/method
- test evidence: action_id + test file + test name + command + result
- forbidden shortcuts check: 必须无 first/current/default item、未来 action stub、Widget owner 泄漏
- remaining gaps: 非空则 phase 只能 in_progress/blocked
- next phase recommendation: 前一 phase closed 后下一 phase 才能 ready

## 15. Closure Precheck

每个 phase 回填 verified/closed 前必须逐项通过：action 属于当前 claimed phase；修改文件和 symbols 在允许范围；forbidden files 未动；future symbols/tests/UI placeholder 不存在；用户可见入口和结果存在；指定 item 测试通过；无新依赖或 owner 泄漏；code/test evidence 路径和名称真实；validation command 通过；remaining gaps 为空；boundary、persistence 和 readonly 约束覆盖。

## 16. Downstream Handoff

Downstream Handoff:
- target downstream skill: none；本轮实现已完成
- implemented scope: P1–P7 全部 31 个 runtime action
- user-visible outcome: 玩家/场地准备 → 随机或手动组队 → 随机或手动排序 → 自动或指定场地分配 → 具象 Court 开赛/比分 → 胜方留场或两组下场 → 历史修正/结束/复制/删除
- persistence: schema v4；v3 非破坏升级；PlaySessionStore.update 单事务保存
- forbidden shortcuts check: PASS；未使用临时 Team 作为有效组、未清库迁移、未把业务 owner 放入 Widget、指定组/场地动作不依赖首项
- remaining gap: 无代码阻塞；真实设备视觉与触控手感复核属于发布前人工检查

## 17. Execution Readiness

- Runtime actions mapped: yes
- Entity states mapped: yes
- Owner boundaries mapped: yes
- Persistence contract mapped: yes
- Failure paths mapped: yes
- Surface actions mapped: yes
- Phase is a user-visible vertical slice: yes
- Phase is not an invisible technical layer: yes
- Phase is small enough: yes
- Current phase minimality gate passed: yes
- Allowed files restricted to current phase symbols: yes
- Non-current action symbols forbidden: yes
- Future code prebuild absent: yes
- CRUD/list actions require item-level UI and non-first-item tests: yes
- Source trace exists: yes
- Execution progress state exists: yes
- Exactly one current phase is ready or claimed: yes
- Closure precheck required before verified/closed: yes
- Current handoff contains exactly one phase: yes
- Downstream skill can start: yes

Verdict: `EXEC SPEC READY`

## 18. Implementation Closure Evidence

| phase | status | implemented evidence | verification evidence |
| --- | --- | --- | --- |
| P1 | closed | `SessionSetupPage`、`SessionRosterPage`、`PlaySession.addCourt/updateSetup`、schema v4 | setup/roster Widget；store round-trip；v3 fixture |
| P2 | closed | `generateRandomGroups/createManualGroup/updateGroup/dissolveGroup/start` 及准备/现场组队入口 | odd/random、指定非首组、Widget entries |
| P3 | closed | `renamePlayer/setResting/restoreWaiting/setLeft/removePlayer` 及指定玩家入口 | state guards；全量 domain/widget regression |
| P4 | closed | group queue 随机/手动排序、自动/指定场地分配、空闲场地删除 | 非首组/非首场地测试；assignment Widget entry |
| P5 | closed | `startMatch/finishMatch/cancelMatch`、具象羽毛球场、胜方/各局比分 | score atomicity；四人 Court；窄屏 1.5x |
| P6 | closed | winner-stays/all-rotate/fill/release 与决策 Dialog | 足/不足候场、刚下场排除、事务 round-trip |
| P7 | closed | correct/complete/duplicate/delete 与 Results/Library 入口 | named-court duplicate；owned-row delete；全量 regression |

Closure summary:
- modified owners: domain model/aggregate/snapshot、Drift schema/store、Roster/Live/Library surfaces、domain/store/widget tests
- dependency delta: none
- navigation delta: none；保留五个现场底部导航
- analyzer: PASS，0 issues
- tests: PASS，包含 schema v3→v4 真实 fixture
- remaining gaps: none blocking；真实设备人工复核不属于自动化闭环

Verdict: `EXECUTION COMPLETE`
