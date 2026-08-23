# 羽搭 / RallyPair 产品方向文档

product_state: ready

本文是“羽搭 / RallyPair”的当前有效产品基线。正式中文名、英文名和内部代号均已确定；后续计划、执行规格、UI 方案、Flutter 实现、上架文案和验收标准应优先读取本文。

## 1. Product Goal

本 App 面向朋友约球、单位球局、社群活动和小型俱乐部日常活动中的组织者，用一台本地设备完成玩家签到、双打分组、场地轮转、赛后比分录入和整场统计。

产品不是普通随机分组器，也不是专业赛事管理系统，而是一个：

> 把“谁在等、谁上哪块场、和谁搭档、打完几场、比分如何”串成连续球局流程的本地组织工具。

核心问题：

- 多人共用少量场地时，口头安排容易漏人、重复上场或让部分玩家等待过久。
- 每轮重新手工组合四人效率低，也容易反复出现相同搭档。
- 分组工具只生成一次结果，无法承接比赛结束、玩家回队和下一场生成。
- 普通比分板只处理一场比赛，无法关联整场球局中的玩家、场地和轮转。
- 组织者通常只有一台设备，无法同时为多块场地逐球计分，因此 V1 采用赛后录入结果。
- 活动结束后需要知道每人打了几场、胜负和合作情况，但不需要专业排名算法。

App 中文名：羽搭。

App 英文名：RallyPair。

内部工程代号：`rally_pair`。

建议商店展示名：

- 中文：羽搭｜羽毛球球局管理
- 英文：RallyPair: Badminton Sessions

## 2. Roles

### LocalOrganizer

- 本地唯一系统角色。
- 通常是约球发起人、群管理员、俱乐部值班人员或现场代为操作的球友。
- 可以创建球局、维护玩家、生成分组、分配场地、录入结果、纠错和结束球局。
- 不需要登录，不存在远端球员账号、裁判权限或俱乐部后台。

球局中的玩家是 `SessionPlayer`，不是 V1 的系统登录角色。

## 3. MVP Scope

V1 必须闭合以下能力：

1. 创建、修改、复制和删除本地球局。
2. 配置球局名称、场地数量、分组策略和比分预设。
3. 添加、修改和移除本场玩家。
4. 支持批量粘贴玩家名单，每行一个名称。
5. 将玩家切换为候场、休息或离场状态。
6. 仅支持羽毛球双打，每场固定四名玩家、两组搭档。
7. 支持完全随机和公平轮转两种分组策略。
8. 公平轮转优先选择已完成场次较少、候场顺序更靠前的玩家。
9. 可选启用“尽量避免连续重复搭档”，无法满足时允许降级生成并明确提示。
10. 为所有可用场地生成待开始比赛，并允许开始前手动替换玩家。
11. 开始比赛后锁定该场四名玩家与场地。
12. 比赛结束后支持仅记录胜方，或录入各局最终比分。
13. 提供 `quick_11` 和 `standard_21` 两种比分预设。
14. 支持取消未完成比赛，取消后不计入玩家场次和胜负。
15. 支持修正已完成比赛的胜方或局分，并重算全部派生统计。
16. 自动生成下一批可用场地分组。
17. 保存每名玩家的完成场次、胜负、得失分、搭档和对手次数。
18. 球局结束后生成本地总结，并允许查看历史球局。
19. 未结束球局在 App 重启后可恢复到原状态。
20. 所有球局、玩家、比赛和统计仅保存在本地。

## 4. Non Goals

- 不做单打、混双规则或跨运动通用排场。
- 不做逐球实时计分、裁判台、发球权和站位自动判断。
- 不做专业赛事报名、种子、签表、赛程、晋级和奖项。
- 不做 Elo、TrueSkill、官方等级或竞技能力评估。
- 不做复杂水平平衡、胜率预测或 AI 分组。
- 不做账号、扫码加入、在线房间、实时同步或远程比分屏。
- 不做地图、场馆搜索、场地预订或商家数据。
- 不做费用、球费、球桶、收款和 AA 结算。
- 不做聊天、公告、社区、公开动态和陌生人约球。
- 不做健康、卡路里、运动轨迹或可穿戴设备接入。
- 不做语音播报、自定义音效、摄像头识别和蓝牙计分设备。
- 不依赖真实球员照片、品牌素材或外部数据才能完成演示。
- 不把球局备注和附件做成通用记事本；附件能力留作后续补充层。

## 5. Feature Classification

### Runtime Required Feature

- 本地球局及配置快照。
- 本场玩家名单和候场状态。
- 双打四人分组。
- 完全随机与公平轮转策略。
- 场地占用和比赛状态。
- 开始前玩家替换。
- 比赛开始、结果录入和取消。
- 玩家回到候场队列。
- 球局完成与历史保存。

### Runtime Support Feature

- 批量粘贴玩家名单。
- 玩家休息、恢复和离场。
- 尽量避免连续重复搭档。
- 已完成比赛结果修正。
- 球局设置复制。
- 未完成球局恢复。
- 胜负、得失分、搭档和对手统计。
- 破坏性删除确认。

### Expansion Feature

- 单打、固定组合和混合赛制。
- 胜者留场、擂台、循环赛、淘汰赛和团体积分。
- 玩家水平标签和轻量平衡分组。
- 等待时长、上场时长和场地利用率。
- 逐球实时计分、发球方和站位提示。
- 球局费用与付款确认。
- 球局资料附件，例如预订截图、活动规则和合照。
- 账号、扫码签到、共同组织和只读比分屏。
- 下一场通知、远端候场查看和多设备同步。
- 分享总结图、CSV 或 PDF 报告。

Expansion Feature 不进入 V1，除非后续明确改变产品目标。

## 6. End-to-End Logic Chain

首次球局链路：

```text
组织者创建球局
-> 设置场地数量、分组策略和比分预设
-> 手动添加或批量粘贴玩家
-> 系统校验至少有四名候场玩家和一块场地
-> 组织者启动球局
-> 系统将玩家放入稳定候场队列
-> 组织者为可用场地生成分组
-> 系统按策略选出玩家并生成待开始比赛
-> 组织者可在开始前替换某位玩家
-> 组织者确认比赛开始
-> 四名玩家进入比赛中，场地进入占用中
-> 比赛结束后组织者选择胜方或录入局分
-> 系统完成比赛、释放场地并更新派生统计
-> 四名玩家按完成顺序回到候场队尾
-> 组织者继续生成下一批比赛
-> 无需继续时结束球局
-> 系统冻结球局并生成总结
```

公平轮转链路：

```text
获取全部 waiting 玩家
-> 按 completedMatchCount 升序排列
-> completedMatchCount 相同时按 queueOrder 升序排列
-> 选取前四名作为候选
-> 在三种双打拆分中比较连续重复搭档惩罚
-> 选择惩罚最低的组合
-> 如全部组合均有重复搭档，允许选择最低惩罚组合并标记 relaxed
-> 将四名玩家设为 assigned
-> 创建 Match.ready
```

赛后结果链路：

```text
Match.in_progress
-> 组织者发起结束比赛
-> 选择 winner_only 或 game_scores
-> 系统校验胜方或局分
-> 原子保存 Match.completed
-> 释放 Court
-> 四名玩家回到 waiting 队尾
-> 从全部 completed Match 重算球局统计
```

中断恢复链路：

```text
球局处于 active
-> 任一分组、开始、取消或结果动作成功后立即保存
-> App 进入后台或被终止
-> 再次打开时读取最近 active 球局
-> 恢复 waiting / resting / assigned / playing 状态
-> 组织者继续当前比赛或修正异常状态
```

## 7. Runtime Action Matrix

### Runtime Action: create_session

- action_id: create_session
- actor: LocalOrganizer
- initiation: 从球局历史发起新建
- source state: 无对应 PlaySession
- target entity: PlaySession
- preconditions: 本地存储可写
- input fields: title, courtCount, pairingPolicy, scorePreset, avoidRecentPartner
- boundary checks: title 去除首尾空白后非空；courtCount 在 1 至 8；枚举值受支持
- state transition: none -> PlaySession.draft
- success result: 创建可编辑球局
- failure result: 不创建半成品球局
- recovery path: 修正输入、释放空间或重试
- owner: PlaySession
- required test assertion: 空标题或无效场地数不能创建球局

### Runtime Action: update_session_setup

- action_id: update_session_setup
- actor: LocalOrganizer
- initiation: 从球局设置修改配置
- source state: PlaySession.draft
- target entity: PlaySession
- preconditions: 球局尚未启动
- input fields: title, courtCount, pairingPolicy, scorePreset, avoidRecentPartner
- boundary checks: 使用 create_session 的全部输入规则
- state transition: PlaySession.draft -> PlaySession.draft
- success result: 原子保存新设置
- failure result: 保留旧设置
- recovery path: 修正输入或取消
- owner: PlaySession
- required test assertion: active 球局不能修改会影响既有比赛的配置

### Runtime Action: add_session_player

- action_id: add_session_player
- actor: LocalOrganizer
- initiation: 从球局设置或现场面添加玩家
- source state: PlaySession.draft / active
- target entity: SessionPlayer
- preconditions: 球局未完成
- input fields: displayName
- boundary checks: 名称非空；同一球局内规范化名称不重复；总人数不超过 64
- state transition: none -> SessionPlayer.waiting
- success result: 玩家追加到候场队尾
- failure result: 不创建玩家
- recovery path: 修改名称或移除无用玩家后重试
- owner: PlaySession
- required test assertion: 重名和第 65 名玩家必须被阻止

### Runtime Action: batch_add_session_players

- action_id: batch_add_session_players
- actor: LocalOrganizer
- initiation: 从名单输入粘贴多行文本
- source state: PlaySession.draft / active
- target entity: SessionPlayer collection
- preconditions: 球局未完成
- input fields: multilineNames
- boundary checks: 去除空行和首尾空白；与已有及批次内名称去重；有效总人数不超过 64
- state transition: none -> multiple SessionPlayer.waiting
- success result: 原子添加全部有效玩家并报告跳过项
- failure result: 超出容量时整批不写入
- recovery path: 缩短名单、处理重名或改为逐个添加
- owner: PlaySession
- required test assertion: 批次内重复名称只能产生一个候选且容量失败不允许部分写入

### Runtime Action: update_session_player

- action_id: update_session_player
- actor: LocalOrganizer
- initiation: 从玩家信息修改名称
- source state: SessionPlayer.waiting / resting / left
- target entity: SessionPlayer
- preconditions: 玩家不在 ready 或 in_progress 比赛中
- input fields: displayName
- boundary checks: 名称非空且在球局内唯一
- state transition: SessionPlayer.current -> SessionPlayer.current
- success result: 保存新名称，历史比赛仍引用同一玩家身份
- failure result: 保留原名称
- recovery path: 修正名称或等待比赛结束
- owner: PlaySession
- required test assertion: playing 玩家不能在比赛中改名

### Runtime Action: set_player_resting

- action_id: set_player_resting
- actor: LocalOrganizer
- initiation: 从候场名单将玩家设为休息
- source state: SessionPlayer.waiting
- target entity: SessionPlayer
- preconditions: 玩家未被分配到待开始比赛
- input fields: playerId
- boundary checks: 玩家属于当前 active 球局且状态为 waiting
- state transition: SessionPlayer.waiting -> SessionPlayer.resting
- success result: 玩家从候场队列移除但保留历史
- failure result: 玩家状态不变
- recovery path: 先取消或替换相关待开始分组
- owner: PlaySession
- required test assertion: assigned 或 playing 玩家不能直接休息

### Runtime Action: restore_player_waiting

- action_id: restore_player_waiting
- actor: LocalOrganizer
- initiation: 从休息或离场名单恢复玩家
- source state: SessionPlayer.resting / left
- target entity: SessionPlayer
- preconditions: 球局 active
- input fields: playerId
- boundary checks: 玩家属于当前球局
- state transition: SessionPlayer.resting / left -> SessionPlayer.waiting
- success result: 玩家加入候场队尾
- failure result: 状态不变
- recovery path: 返回 active 球局后重试
- owner: PlaySession
- required test assertion: 恢复玩家不得插入候场队首

### Runtime Action: set_player_left

- action_id: set_player_left
- actor: LocalOrganizer
- initiation: 从候场或休息名单将玩家设为离场
- source state: SessionPlayer.waiting / resting
- target entity: SessionPlayer
- preconditions: 球局 active，且玩家未被分配到待开始或进行中比赛
- input fields: playerId
- boundary checks: 玩家属于当前球局且状态为 waiting / resting
- state transition: SessionPlayer.waiting / resting -> SessionPlayer.left
- success result: 玩家退出后续排场，但姓名和已完成比赛记录继续保留
- failure result: 玩家状态不变
- recovery path: 先替换、取消或完成玩家所在比赛后重试
- owner: PlaySession
- required test assertion: assigned 或 playing 玩家不能直接离场

### Runtime Action: remove_session_player

- action_id: remove_session_player
- actor: LocalOrganizer
- initiation: 从玩家列表删除本场玩家
- source state: SessionPlayer.waiting / resting / left
- target entity: SessionPlayer
- preconditions: 玩家没有 completed 比赛记录且不在 ready / in_progress 比赛中
- input fields: playerId, confirmation
- boundary checks: 需要确认；有历史比赛时只能设为 left，不能删除身份
- state transition: SessionPlayer.current -> deleted
- success result: 删除无历史玩家
- failure result: 取消或不满足条件时保持原数据
- recovery path: 改为离场，或删除整场球局
- owner: PlaySession
- required test assertion: 有完成比赛的玩家不能被物理删除

### Runtime Action: start_session

- action_id: start_session
- actor: LocalOrganizer
- initiation: 从球局设置确认开始
- source state: PlaySession.draft
- target entity: PlaySession
- preconditions: 至少四名 waiting 玩家；courtCount 至少为 1
- input fields: sessionId
- boundary checks: 所有玩家名称唯一；配置完整；本地保存成功后才进入 active
- state transition: PlaySession.draft -> PlaySession.active
- success result: 冻结核心配置并建立稳定候场顺序
- failure result: 球局保持 draft
- recovery path: 补足玩家或修正配置
- owner: PlaySession
- required test assertion: 三名玩家不能启动双打球局

### Runtime Action: generate_court_assignments

- action_id: generate_court_assignments
- actor: LocalOrganizer
- initiation: 从现场球局面发起排场
- source state: PlaySession.active
- target entity: Match collection
- preconditions: 至少一块 Court.available；至少四名 SessionPlayer.waiting
- input fields: sessionId
- boundary checks: 只为可用场地生成；同一玩家不能同时进入两场；生成数量不超过 floor(waitingCount / 4)
- state transition: SessionPlayer.waiting -> assigned；Court.available -> reserved；none -> Match.ready
- success result: 为尽可能多的可用场地生成待开始比赛
- failure result: 不创建不完整比赛
- recovery path: 等待比赛结束、恢复休息玩家或增加玩家
- owner: PlaySession
- required test assertion: 八名候场玩家和三块空场最多生成两场

### Runtime Action: regenerate_ready_matches

- action_id: regenerate_ready_matches
- actor: LocalOrganizer
- initiation: 对尚未开始的全部分组重新生成
- source state: Match.ready collection
- target entity: Match collection
- preconditions: 不存在被选中分组已经 in_progress
- input fields: confirmation
- boundary checks: 仅取消 ready 比赛；playing 玩家和比赛不得受影响
- state transition: old Match.ready -> canceled；对应 SessionPlayer.assigned -> waiting；Court.reserved -> available；再执行 generate_court_assignments
- success result: 使用下一随机种子重新生成待开始比赛
- failure result: 原分组保持不变
- recovery path: 取消重排或先结束进行中比赛
- owner: PlaySession
- required test assertion: 重排不能改变任何 in_progress 比赛

### Runtime Action: swap_ready_player

- action_id: swap_ready_player
- actor: LocalOrganizer
- initiation: 从待开始比赛选择场上玩家和候场替换玩家
- source state: Match.ready；sourcePlayer.assigned；replacementPlayer.waiting
- target entity: Match
- preconditions: 比赛尚未开始且两名玩家属于同一球局
- input fields: matchId, sourcePlayerId, replacementPlayerId
- boundary checks: 替换后四名玩家唯一；replacement 未出现在其他 ready 比赛
- state transition: sourcePlayer.assigned -> waiting；replacementPlayer.waiting -> assigned；Match.ready -> Match.ready
- success result: 保存替换并将被换下玩家放到候场队首原位置
- failure result: 原分组和队列保持不变
- recovery path: 选择其他候场玩家或取消
- owner: PlaySession
- required test assertion: 同一玩家不能因替换同时出现在两块场地

### Runtime Action: start_match

- action_id: start_match
- actor: LocalOrganizer
- initiation: 从待开始比赛确认开打
- source state: Match.ready；Court.reserved；四名 SessionPlayer.assigned
- target entity: Match
- preconditions: 球局 active，四名玩家和场地状态一致
- input fields: matchId
- boundary checks: 比赛阵容完整且没有重复玩家
- state transition: Match.ready -> in_progress；Court.reserved -> in_play；SessionPlayer.assigned -> playing
- success result: 锁定比赛阵容和场地
- failure result: 所有状态保持原值
- recovery path: 修复阵容冲突或重新分组
- owner: Match
- required test assertion: start_match 必须原子更新比赛、场地和四名玩家

### Runtime Action: finish_match_with_result

- action_id: finish_match_with_result
- actor: LocalOrganizer
- initiation: 从进行中比赛发起结束
- source state: Match.in_progress
- target entity: Match
- preconditions: 球局 active；比赛四名玩家仍完整
- input fields: resultMode, winnerSide, optional gameScores
- boundary checks: winner_only 必须选择一方；game_scores 必须满足当前比分预设且能得出唯一胜方
- state transition: Match.in_progress -> completed；Court.in_play -> available；SessionPlayer.playing -> waiting
- success result: 保存结果，四名玩家按完成顺序进入队尾并重算统计
- failure result: 比赛继续 in_progress，场地与玩家不变
- recovery path: 修正胜方或局分后重试
- owner: Match
- required test assertion: 无效局分不能释放场地或更新统计

### Runtime Action: cancel_match

- action_id: cancel_match
- actor: LocalOrganizer
- initiation: 从 ready 或 in_progress 比赛发起取消
- source state: Match.ready / in_progress
- target entity: Match
- preconditions: 球局 active
- input fields: matchId, confirmation
- boundary checks: 必须确认；completed 比赛不能使用取消动作
- state transition: Match.current -> canceled；Court.reserved / in_play -> available；SessionPlayer.assigned / playing -> waiting
- success result: 比赛不计入场次和胜负，玩家回到候场队首原相对顺序
- failure result: 取消确认时状态不变
- recovery path: 继续比赛或确认取消
- owner: Match
- required test assertion: canceled 比赛不得增加任何玩家统计

### Runtime Action: correct_completed_match

- action_id: correct_completed_match
- actor: LocalOrganizer
- initiation: 从比赛历史修正已完成结果
- source state: Match.completed
- target entity: Match
- preconditions: 所属球局未删除
- input fields: resultMode, winnerSide, optional gameScores, confirmation
- boundary checks: 新结果满足 finish_match_with_result 的结果规则；必须确认统计将重算
- state transition: Match.completed -> Match.completed
- success result: 替换结果并从全部 completed 比赛重算统计
- failure result: 保留原结果和统计
- recovery path: 修正输入或取消
- owner: Match
- required test assertion: 修正胜方后双方胜负与净胜分必须同步重算

### Runtime Action: complete_session

- action_id: complete_session
- actor: LocalOrganizer
- initiation: 从现场球局面发起结束
- source state: PlaySession.active
- target entity: PlaySession
- preconditions: 不存在 Match.ready 或 in_progress
- input fields: sessionId, confirmation
- boundary checks: 必须确认；仍有 reserved / in_play 场地时阻止完成
- state transition: PlaySession.active -> completed；全部非删除玩家 -> archived_in_session
- success result: 冻结分组动作并生成最终总结
- failure result: 球局保持 active
- recovery path: 完成或取消所有当前比赛后重试
- owner: PlaySession
- required test assertion: 有进行中比赛时不能结束球局

### Runtime Action: duplicate_session_setup

- action_id: duplicate_session_setup
- actor: LocalOrganizer
- initiation: 从历史球局选择再次组织
- source state: PlaySession.completed / active
- target entity: PlaySession
- preconditions: 来源球局可读
- input fields: sourceSessionId, newTitle
- boundary checks: 只复制配置和未删除玩家名称；不复制比赛、状态和统计
- state transition: none -> PlaySession.draft
- success result: 创建独立的新球局草稿
- failure result: 不创建不完整副本
- recovery path: 修改标题或手动新建
- owner: PlaySession
- required test assertion: 新球局所有玩家必须为 waiting 且统计为零

### Runtime Action: delete_session

- action_id: delete_session
- actor: LocalOrganizer
- initiation: 从草稿或历史球局发起永久删除
- source state: PlaySession.draft / active / completed
- target entity: PlaySession
- preconditions: 球局存在
- input fields: sessionId, confirmation
- boundary checks: 必须二次确认；active 球局需明确提示未完成比赛将一并删除
- state transition: PlaySession.current -> deleted
- success result: 删除球局及其玩家、比赛和派生统计
- failure result: 取消或删除失败时保留全部数据
- recovery path: 取消、先完成球局或重试
- owner: PlaySession
- required test assertion: 删除失败不能留下部分玩家或孤立比赛

## 8. State Machine

### Entity: PlaySession

- from: none
  event/action: create_session
  guard condition: 设置有效且本地可写
  to: draft
  actor: LocalOrganizer
  side effects: 创建空玩家集合和固定数量场地
  reversible: yes

- from: draft
  event/action: start_session
  guard condition: 至少四名 waiting 玩家且配置完整
  to: active
  actor: LocalOrganizer
  side effects: 冻结核心配置并初始化候场顺序
  reversible: no

- from: active
  event/action: complete_session
  guard condition: 不存在 ready 或 in_progress 比赛
  to: completed
  actor: LocalOrganizer
  side effects: 生成最终摘要并禁用继续排场
  reversible: no

- from: draft / active / completed
  event/action: delete_session
  guard condition: 已确认永久删除
  to: deleted
  actor: LocalOrganizer
  side effects: 删除所属运行数据
  reversible: no

blocked operations per state:

- draft: 不能生成比赛、录入结果或完成球局。
- active: 不能修改场地数量、分组策略和比分预设。
- completed: 不能添加玩家、恢复玩家、生成或开始比赛；允许修正历史结果和复制设置。
- deleted: 禁止全部动作。

terminal states: completed, deleted。

### Entity: SessionPlayer

- from: none
  event/action: add_session_player / batch_add_session_players
  guard condition: 名称有效且容量允许
  to: waiting
  actor: LocalOrganizer
  side effects: 追加到候场队尾
  reversible: yes

- from: waiting
  event/action: set_player_resting
  guard condition: 未进入 ready 比赛
  to: resting
  actor: LocalOrganizer
  side effects: 从候场队列移除
  reversible: yes

- from: resting / left
  event/action: restore_player_waiting
  guard condition: 球局 active
  to: waiting
  actor: LocalOrganizer
  side effects: 追加到候场队尾
  reversible: yes

- from: waiting / resting
  event/action: set_player_left
  guard condition: 未进入 ready 或 in_progress 比赛
  to: left
  actor: LocalOrganizer
  side effects: 退出后续候场轮转并保留历史比赛
  reversible: yes

- from: waiting
  event/action: generate_court_assignments
  guard condition: 被选入唯一一场比赛
  to: assigned
  actor: LocalOrganizer
  side effects: 暂时离开候场队列
  reversible: yes

- from: assigned
  event/action: start_match
  guard condition: 所属 Match.ready
  to: playing
  actor: LocalOrganizer
  side effects: 锁定阵容
  reversible: no

- from: assigned / playing
  event/action: cancel_match
  guard condition: 所属比赛未 completed
  to: waiting
  actor: LocalOrganizer
  side effects: 恢复到候场队首原相对顺序
  reversible: yes

- from: playing
  event/action: finish_match_with_result
  guard condition: 结果有效
  to: waiting
  actor: LocalOrganizer
  side effects: 完成场次计入派生统计并进入队尾
  reversible: no

- from: waiting / resting / left
  event/action: complete_session
  guard condition: 球局不存在 ready 或 in_progress 比赛
  to: archived_in_session
  actor: LocalOrganizer
  side effects: 冻结本场玩家状态与最终统计
  reversible: no

blocked operations per state:

- assigned: 不能改名、休息、离场或删除，只能替换、开始或取消比赛。
- playing: 不能改名、休息、离场、删除或进入其他比赛。
- archived_in_session: 只读。

terminal states: archived_in_session, deleted。

### Entity: Match

- from: none
  event/action: generate_court_assignments
  guard condition: 四名唯一 waiting 玩家和一块 available 场地
  to: ready
  actor: LocalOrganizer
  side effects: 预留场地并设玩家 assigned
  reversible: yes

- from: ready
  event/action: start_match
  guard condition: 阵容与场地状态一致
  to: in_progress
  actor: LocalOrganizer
  side effects: 场地进入 in_play
  reversible: no

- from: ready / in_progress
  event/action: cancel_match
  guard condition: 已确认
  to: canceled
  actor: LocalOrganizer
  side effects: 释放场地，玩家回候场，不计统计
  reversible: no

- from: in_progress
  event/action: finish_match_with_result
  guard condition: 结果有效且唯一胜方可确定
  to: completed
  actor: LocalOrganizer
  side effects: 释放场地、玩家回队尾、重算统计
  reversible: no

- from: completed
  event/action: correct_completed_match
  guard condition: 新结果有效且已确认
  to: completed
  actor: LocalOrganizer
  side effects: 替换结果并重算统计
  reversible: yes

terminal states: completed, canceled。

### Entity: Court

- from: available
  event/action: generate_court_assignments
  guard condition: 有完整四人分组
  to: reserved
  actor: LocalOrganizer
  side effects: 关联 Match.ready
  reversible: yes

- from: reserved
  event/action: start_match
  guard condition: 关联比赛 ready
  to: in_play
  actor: LocalOrganizer
  side effects: 锁定当前比赛
  reversible: no

- from: reserved / in_play
  event/action: cancel_match / finish_match_with_result
  guard condition: 关联比赛进入终态
  to: available
  actor: LocalOrganizer
  side effects: 清除当前比赛引用
  reversible: yes

terminal states: none；Court 生命周期跟随 PlaySession。

## 9. Boundary Check Matrix

### Boundary Check: session_input

- action_id: create_session / update_session_setup
- check_type: input
- condition: title 非空，courtCount 为 1 至 8，策略和比分预设受支持
- block result: 不创建或不修改，原状态保持
- feedback: 指出具体无效字段
- recovery path: 修改字段后重试
- verification assertion: 所有非法枚举和越界场地数均被拒绝

### Boundary Check: player_identity

- action_id: add_session_player / batch_add_session_players / update_session_player
- check_type: duplicate
- condition: 规范化名称在同一球局内唯一且总人数不超过 64
- block result: 单条不写入；批量容量失败时整批不写入
- feedback: 显示重名或容量原因
- recovery path: 改名、减少名单或移除无用玩家
- verification assertion: 名称大小写或空白规范化后仍能识别重复

### Boundary Check: player_state

- action_id: set_player_resting / restore_player_waiting / set_player_left / remove_session_player
- check_type: state
- condition: 玩家处于动作允许状态，且不在 ready / in_progress 比赛中
- block result: 玩家状态和比赛不变
- feedback: 说明玩家当前已被排场或正在比赛
- recovery path: 替换、取消或结束比赛后重试
- verification assertion: assigned 与 playing 状态不能被绕过修改

### Boundary Check: start_capacity

- action_id: start_session
- check_type: capacity
- condition: 至少四名 waiting 玩家且至少一块场地
- block result: 球局保持 draft
- feedback: 显示还缺少的玩家数量
- recovery path: 添加玩家或修正场地数
- verification assertion: 恰好四名玩家可以启动并生成一场

### Boundary Check: assignment_uniqueness

- action_id: generate_court_assignments / regenerate_ready_matches / swap_ready_player
- check_type: ownership
- condition: 每名玩家在任一时刻最多属于一场 ready 或 in_progress 比赛
- block result: 不提交任何冲突分组
- feedback: 指出冲突玩家和场地
- recovery path: 重排或选择其他替换玩家
- verification assertion: 多场批量生成后参与玩家集合无重复 ID

### Boundary Check: assignment_capacity

- action_id: generate_court_assignments
- check_type: capacity
- condition: 每场需要四名 waiting 玩家和一块 available 场地
- block result: 只生成完整比赛，不创建残缺 Match
- feedback: 显示当前可生成场次数量
- recovery path: 等待玩家回队、恢复休息玩家或减少可用场地预期
- verification assertion: 五名玩家只能生成一场并保留一人 waiting

### Boundary Check: match_start_consistency

- action_id: start_match
- check_type: state
- condition: Match.ready、Court.reserved 和四名 SessionPlayer.assigned 相互一致
- block result: 所有状态保持不变
- feedback: 提示阵容状态异常，需要重新分组
- recovery path: 取消异常分组并重新生成
- verification assertion: 任一参与玩家状态异常时不能部分启动比赛

### Boundary Check: result_validity

- action_id: finish_match_with_result / correct_completed_match
- check_type: input
- condition: winner_only 有唯一胜方；game_scores 满足比分预设并能推导唯一胜方
- block result: 比赛与统计保持原值
- feedback: 指出缺少胜方、平局、局数或终局分数错误
- recovery path: 修正后重新提交
- verification assertion: standard_21 的 21:20 和 31:29 无效，22:20 与 30:29 有效

### Boundary Check: match_cancel_destructive

- action_id: cancel_match
- check_type: destructive
- condition: 用户确认取消且比赛未 completed
- block result: 取消确认时比赛继续保持当前状态
- feedback: 说明取消后本场不计入统计
- recovery path: 返回比赛或确认取消
- verification assertion: 未确认不得释放场地和玩家

### Boundary Check: session_completion

- action_id: complete_session
- check_type: state
- condition: 不存在 ready / in_progress 比赛和 reserved / in_play 场地
- block result: 球局保持 active
- feedback: 列出仍未处理的场地
- recovery path: 完成或取消当前比赛
- verification assertion: 所有场地 available 后才允许完成

### Boundary Check: permanent_delete

- action_id: delete_session / remove_session_player
- check_type: destructive
- condition: 已确认，且局部删除不会破坏历史归属
- block result: 取消或失败时数据保持完整
- feedback: 说明将删除的数据范围或为何只能离场
- recovery path: 取消、改为离场或重试
- verification assertion: 删除球局必须全成全败

## 10. Data Ownership Matrix

### Data Ownership: PlaySession

- owner entity: PlaySession
- owned data: 球局配置、玩家身份、候场顺序、场地集合、比赛集合和随机种子序列
- allowed mutations: create_session、update_session_setup、玩家动作、分组动作、complete_session、delete_session
- derived state: 可用场地数、候场人数、球局摘要和全部玩家统计
- forbidden owner leakage: Surface 不得自行维护另一份队列或统计；Match 结果只能通过 PlaySession 聚合
- required test assertion: 重启恢复后队列顺序与派生统计和保存前一致

### Data Ownership: SessionPlayer

- owner entity: PlaySession owns SessionPlayer
- owned data: 本场身份、显示名、当前状态、队列位置
- allowed mutations: 添加、改名、休息、恢复、离场、删除和比赛状态联动
- derived state: 完成场次、胜负、得失分、搭档次数和对手次数全部来自 Match
- forbidden owner leakage: 不允许直接编辑统计数字或由玩家列表自行判断胜负
- required test assertion: 清空并重算统计必须得到与增量结果相同的值

### Data Ownership: Match

- owner entity: PlaySession owns Match
- owned data: 场地引用、两组玩家快照、状态、结果模式、胜方和局分
- allowed mutations: 生成、替换阵容、开始、完成、取消和结果修正
- derived state: 胜方、比赛是否计入统计、每方得失分
- forbidden owner leakage: Court 不得修改比分；统计面不得直接改 Match
- required test assertion: canceled Match 永远不进入统计聚合

### Data Ownership: Court

- owner entity: PlaySession owns Court
- owned data: 本场编号、状态和当前 Match 引用
- allowed mutations: 由生成、开始、完成和取消比赛联动改变
- derived state: availableCourtCount
- forbidden owner leakage: Court 状态不能脱离 Match 独立切换
- required test assertion: 每个 reserved / in_play Court 必须恰好关联一个非终态 Match

## 11. Permissions

- `LocalOrganizer` 拥有当前设备内全部球局动作权限。
- V1 不存在球员自助操作、只读观众、共同组织者或远端管理员。
- 系统文件权限不是主链路依赖；V1 不要求相册、相机、麦克风、定位、通讯录或蓝牙权限。
- 删除球局、取消比赛、修正结果和移除玩家必须由明确用户动作发起。

## 12. Lifecycle

### App Launch

- 优先恢复最近一场 `active` 球局入口，但不自动生成、开始或结束比赛。
- 没有 active 球局时进入球局历史和新建入口。

### Persistence

- 每个成功动作完成后立即持久化 owner 状态。
- 跨实体动作必须原子保存，不能出现比赛已完成但场地仍占用的半状态。
- 派生统计可重建，不作为唯一事实来源。

### Background And Termination

- App 进入后台不改变比赛、场地或玩家状态。
- V1 不依赖后台计时、后台通知或持续任务。
- 被系统终止后从最后一次成功动作恢复。

### Completion And Deletion

- `completed` 球局保留历史、统计和结果修正能力，但不能继续排场。
- `deleted` 为不可恢复终态。
- V1 不做自动归档、自动过期或云端备份。

## 13. Failure / Recovery Matrix

| failure | affected action | state after failure | user feedback | recovery |
| --- | --- | --- | --- | --- |
| 本地存储不可写 | 任一写动作 | 所有 owner 保持旧状态 | 说明保存失败 | 释放空间后重试 |
| 批量名单有空行或重名 | batch_add_session_players | 容量允许时写入唯一有效项并报告跳过项 | 列出跳过数量 | 修改名单后补充 |
| 候场不足四人 | generate_court_assignments | 不创建 Match | 说明还缺几人 | 恢复玩家或等待新玩家 |
| 场地全部占用 | generate_court_assignments | 不改变队列 | 说明暂无空场 | 完成或取消当前比赛 |
| 分组软约束无法满足 | generate_court_assignments | 仍生成最低惩罚组合 | 标记本轮存在重复搭档 | 手动替换或重新生成 |
| 已排场玩家申请休息或离场 | set_player_resting / set_player_left | 玩家及 Match 保持原状态 | 说明玩家已被排场 | 替换、取消或完成比赛后重试 |
| 玩家状态冲突 | start_match | Match 保持 ready | 指出冲突玩家 | 取消并重新排场 |
| 局分无效 | finish_match_with_result | Match 保持 in_progress | 指出无效局分 | 修正后提交 |
| 误取消比赛 | cancel_match | 确认前不改变 | 显示取消影响 | 返回比赛 |
| 误录完成结果 | correct_completed_match | 修正失败时保留原结果 | 说明统计未改变 | 输入有效结果后重试 |
| 结束时仍有比赛 | complete_session | PlaySession 保持 active | 列出未处理场地 | 完成或取消比赛 |
| App 被终止 | 任一 active 流程 | 恢复最后一次成功快照 | 提供继续入口 | 检查现场后继续 |
| 永久删除失败 | delete_session | 保留完整球局 | 说明删除失败 | 重试，不做部分清理 |

## 14. Runtime Surface Responsibilities

### SessionLibrary

- entry source: App 启动或从其他球局返回。
- responsibilities: 展示草稿、进行中和已完成球局；发起新建、复制和删除；优先暴露未完成球局。
- exit/back: 退出 App 不改变球局状态。
- empty state: 允许创建第一场球局，不展示伪造用户数据。
- readonly state: 已完成球局可查看和复制。
- error state: 球局读取失败时不能以空列表覆盖本地数据。
- destructive confirmation: 承担 delete_session 确认。

### SessionSetup

- entry source: 新建草稿或打开已有 draft。
- responsibilities: 编辑核心配置；添加、批量添加、改名和删除无历史玩家；校验启动条件。
- exit/back: 返回保留已成功保存的草稿。
- empty state: 明确至少需要四名玩家。
- readonly state: active / completed 球局不能从此处修改冻结配置。
- error state: 保存失败时保留本地编辑上下文并显示重试。
- destructive confirmation: 承担移除玩家确认。

### LiveSessionBoard

- entry source: start_session 或恢复 active 球局。
- responsibilities: 展示候场、休息、离场、场地和比赛状态；发起分组、重排、替换、开始、取消和结束球局。
- exit/back: 返回不暂停、不取消任何比赛。
- empty state: 候场不足时说明差额和可恢复玩家。
- readonly state: completed 后转入总结责任，不继续操作现场。
- error state: 跨实体状态不一致时阻止继续并提供取消异常分组路径。
- destructive confirmation: 承担重排、取消比赛和结束球局确认。

### MatchResultEntry

- entry source: 从 Match.in_progress 发起结束，或从 Match.completed 发起修正。
- responsibilities: 选择 winner_only / game_scores；校验比分；提交或取消。
- exit/back: 未提交时 Match 保持原状态。
- empty state: 不允许无胜方或空局分提交。
- readonly state: canceled Match 不可进入。
- error state: 显示具体局分错误，不释放场地。
- destructive confirmation: 修正 completed 结果时说明统计将重算。

### SessionSummary

- entry source: complete_session 或历史球局。
- responsibilities: 展示最终比赛和派生统计；进入单场结果修正；发起复制球局设置。
- exit/back: 不改变结果。
- empty state: 无 completed 比赛时显示“本场未产生有效比赛”，仍允许保留球局。
- readonly state: 不提供继续排场。
- error state: 统计重建失败时优先展示原始比赛并阻止错误摘要覆盖。
- destructive confirmation: 不直接承担整场删除，返回 SessionLibrary 处理。

## 15. Domain Entities

```text
PlaySession hasMany SessionPlayer
PlaySession hasMany Court
PlaySession hasMany Match
Match belongsTo PlaySession
Match belongsTo Court
Match hasExactlyFour SessionPlayer references
PlaySession derives PlayerSummary from completed Match collection
```

概念约束：

- `PlaySession` 是唯一聚合根。
- `SessionPlayer` 仅在一场球局内有效，不等同于全局账号。
- `Match` 保存当场阵容快照，玩家后续改名不改变身份引用。
- `Court` 只是本场编号和占用状态，不代表真实场馆数据。
- `PlayerSummary` 是派生结果，不是可编辑实体。

## 16. Runtime Boundaries

### Pairing Policy

- `random`: 使用本场随机种子对 waiting 队列洗牌，按四人切分。
- `fair_rotation`: 先按 completedMatchCount，再按 queueOrder 选人。
- `avoidRecentPartner` 是软约束，只比较候选四人的三种双打拆分。
- V1 不按性别、水平、胜率或体力做权重。
- 相同输入和相同随机种子必须得到可重复结果，方便测试。

### Score Preset

- `quick_11`: 一局定胜负，先到 11 分获胜，不启用加分延长。
- `standard_21`: 三局两胜；每局 21 分；20 平后领先 2 分获胜；30 分封顶。
- `winner_only`: 只保存胜方，不产生得失分。
- `game_scores`: 保存各局最终比分并派生胜方。
- V1 不跟踪逐球历史、发球权、局间换边和暂停。

### Statistics

- completedMatchCount 只统计 `Match.completed`。
- win / loss 只来自唯一胜方。
- pointsFor / pointsAgainst 只聚合 `game_scores`，winner_only 不伪造分数。
- partnerCount 和 opponentCount 根据每场阵容快照计算。
- 结果修正后从 Match 集合全量重算，避免增量回滚错误。

### Local-Only Boundary

- 不请求网络即可完成全部 V1 主链路。
- 不需要任何专用图片、音频或视频素材。
- App 图标与常规 UI 图标不属于业务测试数据。
- 所有审核演示都能使用代码生成的虚构玩家和比赛完成。

## 17. Test Data And Fixture Plan

### Fixture Generation

- 使用固定种子 `20260722` 生成可重复数据。
- 内置仅用于开发和截图构建的虚构名称池，不在正式空状态自动展示。
- 基础名称：林一、陈舟、周宁、苏禾、顾言、许川、沈青、唐远、江禾、陆宁、程野、夏言。
- 不使用真人照片、球拍品牌、场馆名称或网络数据。

### Required Fixtures

1. `empty_draft`: 0 名玩家、2 块场地，用于空状态。
2. `ready_draft`: 8 名 waiting 玩家、2 块场地，可启动。
3. `active_waiting`: 12 名玩家，其中 8 名 waiting、2 名 resting、2 名 left。
4. `active_ready_matches`: 8 名 assigned 玩家、2 场 Match.ready、4 名 waiting。
5. `active_in_progress`: 8 名 playing 玩家、2 场 Match.in_progress、4 名 waiting。
6. `active_mixed`: 1 场 completed、1 场 in_progress、4 名 waiting、1 名 resting。
7. `completed_session`: 12 名玩家、10 场 completed，混合 winner_only 与合法 game_scores。
8. `correction_case`: 一场胜方录反的 completed Match，用于重算统计。
9. `relaxed_pairing_case`: 四名候选的搭档组合均重复，用于软约束降级提示。

### Required Score Samples

- quick_11: 11:7。
- standard_21 straight games: 21:15, 21:18。
- standard_21 three games: 21:18, 17:21, 22:20。
- valid cap: 30:29。
- invalid samples: 20:20, 21:20, 31:29, 三局全部由同一方获胜但仍录入第三局。

### State Coverage

- 空状态：无球局、无玩家、候场不足。
- 进行中：ready、in_progress、多场地混合状态。
- 完成：正常完成和无有效比赛完成。
- 异常：重名、容量超限、玩家冲突、比分无效和存储失败。
- 撤销与纠错：重排前确认、取消比赛、修正已完成结果。

## 18. Assumptions and Unknowns

### Assumption

- assumption: V1 仅支持双打，每场四人。
- why low risk: 当前核心痛点来自多人双打轮转，限制后能显著降低规则和 UI 复杂度。
- affected logic: 分组容量、场地占用、搭档和对手统计。
- validation needed: 上架前用 8、10、12、13 人及 1 至 4 块场地完成手工走查。

### Assumption

- assumption: 单设备组织者采用赛后结果录入，不逐球计分。
- why low risk: 一台设备无法同时可靠操作多块场地，赛后录入更符合球局组织职责。
- affected logic: Match 状态和结果录入。
- validation needed: 原型阶段确认从结束比赛到录入结果的操作足够短。

### Assumption

- assumption: 取消比赛不计入任何玩家场次。
- why low risk: 中断比赛没有稳定可比较结果，排除统计最易理解。
- affected logic: 玩家场次、公平轮转和总结。
- validation needed: 通过取消后重新排场测试验证队列顺序符合预期。

### Assumption

- assumption: 分组避重复是软约束，无法满足时允许降级。
- why low risk: 小人数和多轮场景不可能永久避免重复，硬阻塞会让现场流程中断。
- affected logic: generate_court_assignments。
- validation needed: 在 4、5、8 人多轮 fixture 中检查提示和结果。

### Naming Decision

- decision: 中文正式名为“羽搭”，英文正式名为“RallyPair”，内部工程代号为 `rally_pair`。
- rationale: “羽搭”以品牌化方式关联羽毛球搭档、分组和配合，不把功能描述直接作为主名称；“RallyPair”延续对局与搭档语义，并由商店副标题补充球局管理定位。
- rejected naming: “羽局 / RallyQueue”与“羽球局 / ShuttleRounds”均已于 2026-08-23 被否决，不得再次作为正式名推荐。
- conflict screen: 截至 2026-08-23，App Store、Google Play 与公开网页初步检索未发现名为 RallyPair 的同名应用；该结果仅用于产品命名筛选，不替代正式商标与主体名称检索。
- affected action/state/boundary: 工程初始化、应用显示名、商店物料和后续品牌设计统一使用本命名，不改变运行逻辑。

### Unknown

- unknown: V1 是否需要在结果中记录比赛耗时。
- affected action/state/boundary: 可能增加时间锚点和中断恢复逻辑。
- risk: 增加但不改变核心球局闭环。
- blocks readiness: no
- required clarification: 默认不进入 V1，后续作为 feature-impact-analysis 评估。

## 19. Launch-Blocking TODOs

当前没有依赖外部系统的 Launch-Blocking TODO。

正式开发前仍需完成以下非阻塞前置项：

- 在计划阶段为比分校验和分组确定性建立完整测试任务。
- 在 UI 阶段验证单手现场操作和多场地状态辨识，不改变本需求逻辑。

## 20. Logic Completeness Validation

- Product Goal、角色、MVP 与 Non Goals 已明确。
- 主链路覆盖创建、启动、分组、替换、开打、结果、取消、纠错、继续轮转和完成。
- Runtime Required Feature 均有最小可执行动作。
- PlaySession、SessionPlayer、Match 和 Court 均有状态机和 owner。
- 每个核心动作均有边界、失败结果、恢复路径和测试断言。
- 多场地单设备与赛后比分录入之间不存在职责冲突。
- 测试数据可全部由固定种子和结构化 fixture 生成。
- 不存在 `blocks readiness: yes` 的 Unknown。

Logic Completeness Gate: PASS。

## 21. Requirement Logic Readiness

Verdict: `REQUIREMENT LOGIC READY`

本文可作为后续 `plan-spec`、`exec-spec`、App 设计和 Flutter 实现的基础逻辑输入。任何新增的单打、实时计分、费用、赛事、排名或联网能力必须先执行 `feature-impact-analysis`，不得直接并入 V1。
