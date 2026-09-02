# 羽搭 / RallyPair 产品方向文档

product_state: ready
baseline_revision: 2026-09-02

本文是“羽搭 / RallyPair”的当前有效产品基线。正式中文名、英文名和内部代号均已确定；后续计划、执行规格、App 设计、Flutter 实现、数据迁移和验收标准必须优先读取本文。

2026-08-30 起，V1 收敛为单场地，并在创建时选择单打或双打。单打以个人为候场和轮转单位；双打继续使用持续双人组。11 分和 21 分都只记录一局最终比分。旧多场地和旧多局数据只用于非破坏兼容。

2026-09-02 起，现场交互收敛为单一球局工作台。开始首场会一次完成启动、队首分配和开赛；轮换方式在创建球局时确定并于开局后冻结，每场结束只提交结果，系统自动轮转并准备下一场；球友、候场顺序和比赛记录作为上下文工具，不再与现场主循环并列为底部导航。

## 1. Product Goal

本 App 面向朋友约球、单位球局、社群活动和小型俱乐部日常活动中的组织者，用一台本地设备完成玩家加入、双人组编排、候场顺序、场地分配、分场地比分录入、上下场轮转和整场统计。

产品不是普通随机分组器，也不是专业赛事管理系统，而是一个：

> 把“有哪些人、谁和谁一组、哪组先上、在哪块场、当前比分、谁留场、谁下场、下一组是谁”串成连续现场流程的本地组织工具。

核心问题：

- 多人共用少量场地时，口头安排容易漏组、重复上场或忘记下一组。
- 随机组队、手动组队、随机上场顺序和手动排序是不同动作，不能被合并成一个不可控算法。
- 比赛结束不仅产生比分，还必须决定本场两组如何上下场并立即承接下一场。
- 组织者需要同时掌握多块场地的当前对阵、比分和轮转状态。
- 场地不是一条文字记录，而是承载两组、四名玩家、比分和轮转动作的核心运行对象。
- 一台设备无法可靠逐球记录多块场地，因此 V1 采用赛后录入胜方或最终局分。

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
- 可以创建球局、维护玩家和场地、组队、排序、分配场地、录入比分、决定上下场、纠错和结束球局。
- 不需要登录，不存在远端球员账号、裁判权限或俱乐部后台。

球局中的玩家是 `SessionPlayer`，双人组合是 `PairingGroup`，两者都不是 V1 的系统登录角色。

## 3. MVP Scope

V1 必须闭合以下能力：

1. 创建、修改、复制和删除本地球局。
2. 配置球局名称、比分预设和整场必选的轮转方式。
3. 添加、修改和移除本场玩家。
4. 支持批量粘贴玩家名单，每行一个名称。
5. 将未上场玩家切换为可组队、休息或离场状态。
6. 动态添加、命名和移除本场场地；进行中的场地不能删除。
7. 创建时必须选择单打或双打；开始后赛制冻结。
8. 支持随机组队：对当前可组队且未成组的玩家洗牌后两两成组。
9. 支持手动组队：组织者选择两名未成组玩家建立一组。
10. 奇数玩家允许保持未成组，不创建残缺双人组。
11. 双人组创建后持续存在，直到组织者在允许状态下主动换人或解散。
12. 支持随机打乱候场组顺序。
13. 支持手动调整候场组顺序。
14. 新建和复制球局固定一块场地，不提供场地增删。
15. 单打从个人候场队列选择两人；双打从组候场队列选择两组。
16. 具象化羽毛球场按赛制承载两人或四名玩家和比赛状态。
17. 比赛开始后锁定当前两名或四名玩家。
18. 比赛结束后支持仅记录胜方，或录入一局最终比分。
19. 提供 `quick_11` 和 `standard_21` 两种比分预设。
20. 比分提交后，场地进入 `awaiting_rotation`，不能直接释放或让四名玩家全部回队。
21. 支持 `winner_stays`：胜方留场、败方下场、候场队首下一组补位。
22. 支持 `all_rotate`：两组全部下场、从候场队首重新选择两组上场。
23. 本轮刚下场的组不得在同一次轮转中立即重新补位；候场不足时场地进入等待状态。
24. 支持取消未完成比赛，取消后不计入比赛统计。
25. 支持修正已完成比赛结果并重算全部派生统计；已执行的历史轮转不因比分修正而自动回滚。
26. 保存每名玩家和每个双人组的完成场次、胜负、得失分、搭档和对手关系。
27. 球局结束后生成本地总结，展示完成场数、上场覆盖、人均出场、实际参赛球友的胜负与胜率，并允许查看历史球局。
28. 未结束球局在 App 重启后恢复到原场地、分组、队列、比分和轮转状态。
29. 所有球局、玩家、双人组、场地、比赛和统计仅保存在本地。
30. 新球局点击开始后必须直接进入首场比赛，不经过空球场和重复开赛确认。
31. 每场结算只收集胜方或比分；系统必须自动应用创建球局时选择的轮转方式，不提供单场覆盖。
32. 现场以当前比赛为唯一主工作区；球友、候场顺序和比赛记录降为上下文工具。
33. 结束球局时，系统在确认后取消未完成比赛、保留已记录结果、释放留场单位并生成总结。

## 4. Non Goals

- 不做混双、单场临时切换赛制或跨运动通用排场。
- 不做逐球实时计分、裁判台、发球权和站位自动判断。
- 不做专业赛事报名、种子、签表、赛程、晋级和奖项。
- 不做 Elo、TrueSkill、官方等级或竞技能力评估。
- 不做复杂水平平衡、胜率预测或 AI 组队。
- 不做账号、扫码加入、在线房间、实时同步或远程比分屏。
- 不做地图、场馆搜索、场地预订或商家数据。
- 不做费用、球费、球桶、收款和 AA 结算。
- 不做聊天、公告、社区、公开动态和陌生人约球。
- 不做健康、卡路里、运动轨迹或可穿戴设备接入。
- 不做语音播报、自定义音效、摄像头识别和蓝牙计分设备。
- 不依赖真实球员照片、品牌素材或外部数据才能完成演示。
- 不把胜方留场扩展成升降级联赛、擂台排名或竞技积分制度。

## 5. Feature Classification

### Runtime Required Feature

- 本地球局及配置快照。
- 本场玩家、球局级单双打形式和唯一具象场地。
- 单打个人候场；双打随机或手动组成持续双人组。
- 个人或双人组的随机候场顺序与手动候场排序。
- 与赛制人数一致的场地分配和比赛状态。
- 比赛开始、结果录入和取消。
- `winner_stays` 与 `all_rotate` 两种赛后轮转。
- 创建球局时必须选择整场轮转方式，开局后冻结。
- 场地等待下一组和继续下一场。
- 球局完成与历史保存。

### Runtime Support Feature

- 批量粘贴玩家名单。
- 玩家休息、恢复和离场。
- 等待组换人和解散。
- 已完成比赛结果修正。
- 球局设置复制。
- 未完成球局恢复。
- 胜负、得失分、搭档和对手统计。
- 破坏性删除确认。

### Expansion Feature

- 单打、固定组合模板和混合赛制。
- 自动水平平衡组队。
- 升降场、擂台、循环赛、淘汰赛和团体积分。
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
组织者创建球局并选择单打或双打
-> 添加或批量粘贴玩家
-> 系统自动建立唯一场地
-> 单打进入个人候场；双打选择随机组队或手动组队
-> 双打生成持续 PairingGroup；奇数剩余玩家保持 ungrouped
-> 组织者随机打乱候场单位顺序或手动排序
-> 组织者点击开始第一场
-> 系统原子完成 PlaySession.active、队首分配与 Match.in_progress
-> 具象化场地显示单打两人或双打四人的空间位置
-> 比赛结束后组织者只选择胜方或可选比分
-> 系统自动使用创建时保存的球局轮转方式
-> 系统原子完成 Match.completed、组队列更新与下一场 Match.ready
-> 组织者确认下一场实际开始
-> 无需继续时确认结束球局
-> 系统取消未完成比赛、保留已记录结果并释放留场单位
-> 系统冻结球局并生成总结
```

随机组队链路：

```text
获取全部 eligible 且 ungrouped 玩家
-> 使用本场随机种子洗牌
-> 按相邻两人创建 PairingGroup.waiting
-> 若剩余一人，则保持 SessionPlayer.ungrouped
-> 新组按创建顺序进入组候场队尾
```

手动组队链路：

```text
组织者选择两名 eligible 且 ungrouped 玩家
-> 校验玩家唯一且未被其他有效组占用
-> 创建 PairingGroup.waiting
-> 新组进入候场队尾
```

候场排序链路：

```text
随机排序：仅洗牌 PairingGroup.waiting 并重写 queueOrder
手动排序：组织者移动 waiting 组并保存新的稳定 queueOrder
assigned / playing / awaiting_rotation / staying 组不参与排序
```

胜方留场链路：

```text
Match.result_recorded + Court.awaiting_rotation
-> 选择 winner_stays
-> 胜方 PairingGroup.awaiting_rotation -> staying
-> 败方 PairingGroup.awaiting_rotation -> waiting，并进入队尾
-> 从轮转前已在 waiting 的队首选择下一组
-> 有下一组：胜方与下一组进入 Match.ready，Court.ready
-> 无下一组：胜方保持 staying，Court.waiting_opponent
-> 原 Match -> completed
```

两组下场链路：

```text
Match.result_recorded + Court.awaiting_rotation
-> 选择 all_rotate
-> 当前两组进入 waiting 队尾
-> 从轮转前已在 waiting 的队首选择两组
-> 有两组：创建 Match.ready，Court.ready
-> 不足两组：不创建残缺比赛，Court.available
-> 原 Match -> completed
```

中断恢复链路：

```text
球局处于 active
-> 任一玩家、场地、组队、排序、分配、比分或轮转动作成功后立即保存
-> App 进入后台或被终止
-> 再次打开时读取最近 active 球局
-> 恢复 ungrouped / waiting / assigned / playing / awaiting_rotation / staying
-> 恢复每块场地的当前比赛、比分和轮转上下文
-> 组织者从未完成动作继续
```

## 7. Runtime Action Matrix

### Runtime Action: create_session

- action_id: create_session
- actor: LocalOrganizer
- initiation: 从球局历史发起新建
- source state: 无对应 PlaySession
- target entity: PlaySession
- preconditions: 本地存储可写
- input fields: title, scorePreset, defaultRotationMode
- boundary checks: title 去除首尾空白后非空；枚举值受支持
- state transition: none -> PlaySession.draft
- success result: 创建可编辑球局
- failure result: 不创建半成品球局
- recovery path: 修正输入、释放空间或重试
- owner: PlaySession
- required test assertion: 空标题或无效枚举不能创建球局

### Runtime Action: update_session_setup

- action_id: update_session_setup
- actor: LocalOrganizer
- initiation: 从球局设置修改配置
- source state: PlaySession.draft
- target entity: PlaySession
- preconditions: 球局尚未启动
- input fields: title, scorePreset, defaultRotationMode
- boundary checks: 使用 create_session 的全部输入规则
- state transition: PlaySession.draft -> PlaySession.draft
- success result: 原子保存新设置
- failure result: 保留旧设置
- recovery path: 修正输入或取消
- owner: PlaySession
- required test assertion: active 球局不能修改会改变既有比赛解释的配置

### Runtime Action: start_session

- action_id: start_session
- actor: LocalOrganizer
- initiation: 从组队或排序完成态确认开始球局
- source state: PlaySession.draft
- target entity: PlaySession
- preconditions: 至少四名 eligible 玩家、两组 waiting 和一块 available 场地
- input fields: sessionId
- boundary checks: 所有 waiting 组均为完整双人组；比分预设和默认轮转枚举有效
- state transition: PlaySession.draft -> active
- success result: 冻结比分预设并开放场地分配、比赛和轮转动作
- failure result: 球局保持 draft，不分配任何场地
- recovery path: 补充玩家、完成组队、添加场地或修正设置后重试
- owner: PlaySession
- required test assertion: 少于两组或没有场地时不能启动球局

### Runtime Action: add_session_player

- action_id: add_session_player
- actor: LocalOrganizer
- initiation: 从名单或现场面添加玩家
- source state: PlaySession.draft / active
- target entity: SessionPlayer
- preconditions: 球局未完成
- input fields: displayName
- boundary checks: 名称非空；规范化名称在本球局唯一；总人数不超过 64
- state transition: none -> SessionPlayer.ungrouped
- success result: 玩家进入可组队名单
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
- state transition: none -> multiple SessionPlayer.ungrouped
- success result: 原子添加全部有效玩家并报告跳过项
- failure result: 超出容量时整批不写入
- recovery path: 缩短名单、处理重名或改为逐个添加
- owner: PlaySession
- required test assertion: 批次内重复只产生一名玩家，容量失败不允许部分写入

### Runtime Action: update_session_player

- action_id: update_session_player
- actor: LocalOrganizer
- initiation: 从玩家信息修改名称
- source state: SessionPlayer.ungrouped / grouped / resting / left
- target entity: SessionPlayer
- preconditions: 玩家所属组未 assigned、playing、awaiting_rotation 或 staying
- input fields: displayName
- boundary checks: 名称非空且在球局内唯一
- state transition: SessionPlayer.current -> SessionPlayer.current
- success result: 保存新名称，历史引用仍保持同一身份
- failure result: 保留原名称
- recovery path: 修正名称或等待场地流转完成
- owner: PlaySession
- required test assertion: 场上组的玩家不能在比赛中改名

### Runtime Action: set_player_resting

- action_id: set_player_resting
- actor: LocalOrganizer
- initiation: 将未成组玩家设为休息
- source state: SessionPlayer.ungrouped
- target entity: SessionPlayer
- preconditions: 玩家不属于有效 PairingGroup
- input fields: playerId
- boundary checks: 玩家属于当前 active 球局且未成组
- state transition: SessionPlayer.ungrouped -> resting
- success result: 玩家退出可组队池但保留历史
- failure result: 玩家状态不变
- recovery path: 先解散等待组或完成场地流转
- owner: PlaySession
- required test assertion: grouped 或 playing 玩家不能直接休息

### Runtime Action: restore_player_eligible

- action_id: restore_player_eligible
- actor: LocalOrganizer
- initiation: 从休息或离场名单恢复玩家
- source state: SessionPlayer.resting / left
- target entity: SessionPlayer
- preconditions: 球局 active
- input fields: playerId
- boundary checks: 玩家属于当前球局
- state transition: SessionPlayer.resting / left -> ungrouped
- success result: 玩家重新进入可组队池
- failure result: 状态不变
- recovery path: 返回 active 球局后重试
- owner: PlaySession
- required test assertion: 恢复玩家不得自动加入已有双人组

### Runtime Action: set_player_left

- action_id: set_player_left
- actor: LocalOrganizer
- initiation: 将未成组或休息玩家设为离场
- source state: SessionPlayer.ungrouped / resting
- target entity: SessionPlayer
- preconditions: 玩家不属于有效 PairingGroup
- input fields: playerId
- boundary checks: 玩家属于当前球局且未被场地或双人组锁定
- state transition: SessionPlayer.ungrouped / resting -> left
- success result: 玩家退出后续组队但保留历史
- failure result: 状态不变
- recovery path: 先解散等待组或处理完当前比赛
- owner: PlaySession
- required test assertion: 场上玩家不能直接离场

### Runtime Action: remove_session_player

- action_id: remove_session_player
- actor: LocalOrganizer
- initiation: 从玩家列表永久移除本场玩家
- source state: SessionPlayer.ungrouped / resting / left
- target entity: SessionPlayer
- preconditions: 玩家无 completed 比赛且不属于有效 PairingGroup
- input fields: playerId, confirmation
- boundary checks: 需要确认；有历史比赛时只能设为 left
- state transition: SessionPlayer.current -> deleted
- success result: 删除无历史、未成组玩家
- failure result: 保留玩家及全部引用
- recovery path: 改为离场或删除整场球局
- owner: PlaySession
- required test assertion: 有历史或有效组引用的玩家不能物理删除

### Runtime Action: add_court

- action_id: add_court
- actor: LocalOrganizer
- initiation: 从球局设置或现场场地面添加场地
- source state: PlaySession.draft / active
- target entity: Court
- preconditions: 球局未完成；现有场地少于 8
- input fields: displayName
- boundary checks: 名称非空且在本球局唯一
- state transition: none -> Court.available
- success result: 创建可承载比赛的具体场地
- failure result: 不创建场地
- recovery path: 修改名称、移除空闲场地或重试
- owner: PlaySession
- required test assertion: 重名场地和第 9 块场地必须被阻止

### Runtime Action: remove_court

- action_id: remove_court
- actor: LocalOrganizer
- initiation: 从场地列表移除当前不使用的场地
- source state: Court.available
- target entity: Court
- preconditions: 场地无当前 Match 且无 staying 组
- input fields: courtId, confirmation
- boundary checks: 需要确认；ready / in_play / awaiting_rotation / waiting_opponent 场地不能删除
- state transition: Court.available -> deleted
- success result: 删除空闲场地，历史 Match 仍保留场地快照
- failure result: 场地和比赛不变
- recovery path: 先完成或取消当前流转
- owner: PlaySession
- required test assertion: 非 available 场地不能被删除

### Runtime Action: generate_random_groups

- action_id: generate_random_groups
- actor: LocalOrganizer
- initiation: 从分组面选择随机组队
- source state: multiple SessionPlayer.ungrouped
- target entity: PairingGroup collection
- preconditions: 至少两名 eligible ungrouped 玩家
- input fields: optional selectedPlayerIds
- boundary checks: 每名玩家最多进入一个有效组；只使用 eligible ungrouped 玩家
- state transition: 两名 SessionPlayer.ungrouped -> grouped；none -> PairingGroup.waiting
- success result: 使用确定性随机种子洗牌并两两成组；奇数剩余玩家保持 ungrouped
- failure result: 不创建残缺组或重复成员组
- recovery path: 增加玩家、改用手动组队或调整选择范围
- owner: PlaySession
- required test assertion: 五名玩家生成两组且恰好一人保持 ungrouped

### Runtime Action: create_manual_group

- action_id: create_manual_group
- actor: LocalOrganizer
- initiation: 从分组面手动选择两名玩家
- source state: two SessionPlayer.ungrouped
- target entity: PairingGroup
- preconditions: 两名玩家 eligible 且属于同一球局
- input fields: firstPlayerId, secondPlayerId
- boundary checks: 两个 ID 不同；两人均未被有效组占用
- state transition: 两名 SessionPlayer.ungrouped -> grouped；none -> PairingGroup.waiting
- success result: 新组进入组候场队尾
- failure result: 玩家和组集合保持不变
- recovery path: 选择其他玩家或先解散等待组
- owner: PlaySession
- required test assertion: 同一玩家不能同时属于两个有效组

### Runtime Action: update_waiting_group

- action_id: update_waiting_group
- actor: LocalOrganizer
- initiation: 从等待组替换其中一名玩家
- source state: PairingGroup.waiting
- target entity: PairingGroup
- preconditions: 原组未分配到场地；替换玩家为 eligible ungrouped
- input fields: groupId, sourcePlayerId, replacementPlayerId
- boundary checks: 替换后保持两名唯一成员；replacement 不属于其他有效组
- state transition: source SessionPlayer.grouped -> ungrouped；replacement ungrouped -> grouped；PairingGroup.waiting -> waiting
- success result: 保留组身份和 queueOrder，更新成员
- failure result: 原组和玩家状态保持不变
- recovery path: 选择其他玩家或取消
- owner: PlaySession
- required test assertion: 场上组不能换人，等待组换人不改变队列位置

### Runtime Action: dissolve_waiting_group

- action_id: dissolve_waiting_group
- actor: LocalOrganizer
- initiation: 从等待组发起解散
- source state: PairingGroup.waiting
- target entity: PairingGroup
- preconditions: 组未分配到场地
- input fields: groupId, confirmation
- boundary checks: 需要确认；assigned / playing / awaiting_rotation / staying 组不能解散
- state transition: PairingGroup.waiting -> dissolved；两名 SessionPlayer.grouped -> ungrouped
- success result: 释放两名玩家并从候场组队列移除该组
- failure result: 组、玩家和队列保持不变
- recovery path: 取消或等待场地流转完成
- owner: PlaySession
- required test assertion: 解散等待组后两名玩家都可重新组队

### Runtime Action: randomize_group_queue

- action_id: randomize_group_queue
- actor: LocalOrganizer
- initiation: 从轮转面随机打乱上场顺序
- source state: PairingGroup.waiting collection
- target entity: PairingGroup collection
- preconditions: 至少两组 waiting
- input fields: confirmation
- boundary checks: 仅重排 waiting 组；其他状态组不受影响
- state transition: PairingGroup.waiting -> waiting with new queueOrder
- success result: 使用下一随机种子生成稳定可恢复的新顺序
- failure result: 原顺序保持不变
- recovery path: 取消或改用手动排序
- owner: PlaySession
- required test assertion: 随机排序不能移动任何 assigned 或 playing 组

### Runtime Action: reorder_waiting_group

- action_id: reorder_waiting_group
- actor: LocalOrganizer
- initiation: 从轮转面手动移动等待组
- source state: PairingGroup.waiting
- target entity: PairingGroup queue
- preconditions: 目标位置位于 waiting 队列范围
- input fields: groupId, targetIndex
- boundary checks: 只能移动 waiting 组；保存后 queueOrder 连续且唯一
- state transition: PairingGroup.waiting -> waiting with new queueOrder
- success result: 原子保存新的候场顺序
- failure result: 队列保持原顺序
- recovery path: 重新选择位置或刷新状态
- owner: PlaySession
- required test assertion: 手动排序后重启 App 顺序保持一致

### Runtime Action: assign_next_groups_to_court

- action_id: assign_next_groups_to_court
- actor: LocalOrganizer
- initiation: 从空闲场地选择按队列分配
- source state: Court.available；至少两组 PairingGroup.waiting
- target entity: Court, Match, PairingGroup
- preconditions: 球局 active
- input fields: courtId
- boundary checks: 取队首两组；每组只能属于一个非终态 Match
- state transition: 两组 waiting -> assigned；Court.available -> ready；none -> Match.ready
- success result: 双打场地具象化显示两组四人的位置
- failure result: 不创建残缺 Match
- recovery path: 补充组、调整队列或手动选择
- owner: PlaySession
- required test assertion: 只有一组 waiting 时不能创建 Match

### Runtime Action: assign_specific_groups_to_court

- action_id: assign_specific_groups_to_court
- actor: LocalOrganizer
- initiation: 从空闲场地手动选择两组
- source state: Court.available；两组 PairingGroup.waiting
- target entity: Court, Match, PairingGroup
- preconditions: 两组不同且属于当前球局
- input fields: courtId, firstGroupId, secondGroupId
- boundary checks: 两组均 waiting 且未被其他场地占用
- state transition: 两组 waiting -> assigned；Court.available -> ready；none -> Match.ready
- success result: 指定两组进入该场地并从候场队列暂时移除
- failure result: 场地、组和队列保持不变
- recovery path: 选择其他组或取消
- owner: PlaySession
- required test assertion: 同一组不能同时分配到两块场地

### Runtime Action: start_match

- action_id: start_match
- actor: LocalOrganizer
- initiation: 从具象化场地确认开打
- source state: Match.ready；Court.ready；两组 PairingGroup.assigned
- target entity: Match
- preconditions: 两组共四名唯一玩家且场地引用一致
- input fields: matchId
- boundary checks: Match、Court、PairingGroup 和成员引用相互一致
- state transition: Match.ready -> in_progress；Court.ready -> in_play；两组 assigned -> playing
- success result: 锁定该场阵容
- failure result: 所有状态保持原值
- recovery path: 修复冲突、取消分配或重新分配
- owner: Match
- required test assertion: start_match 必须原子更新 Match、Court 和两组状态

### Runtime Action: record_match_result

- action_id: record_match_result
- actor: LocalOrganizer
- initiation: 从进行中场地发起比分录入
- source state: Match.in_progress
- target entity: Match
- preconditions: 球局 active；两组与四名玩家仍完整
- input fields: resultMode, winnerSide, optional gameScores
- boundary checks: winner_only 有唯一胜方；game_scores 满足比分预设并推导唯一胜方
- state transition: Match.in_progress -> result_recorded；Court.in_play -> awaiting_rotation；两组 playing -> awaiting_rotation
- success result: 原子保存比分并等待上下场决策，不释放场地
- failure result: 比赛继续 in_progress，场地和组不变
- recovery path: 修正胜方或局分后重试
- owner: Match
- required test assertion: 无效比分不能让 Court 进入 awaiting_rotation

### Runtime Action: resolve_rotation_winner_stays

- action_id: resolve_rotation_winner_stays
- actor: LocalOrganizer
- initiation: 从 awaiting_rotation 场地选择胜方留场
- source state: Match.result_recorded；Court.awaiting_rotation；两组 PairingGroup.awaiting_rotation
- target entity: Match, Court, PairingGroup queue
- preconditions: 结果有唯一胜方
- input fields: matchId
- boundary checks: 本轮刚下场败方不能作为本轮补位组；下一组必须来自轮转前 waiting 集合
- state transition: 有补位组时胜方与补位组 -> assigned；无补位组时胜方 -> staying；败方 -> waiting 队尾；原 Match -> completed
- success result: 有下一组时创建下一 Match.ready 并让胜方与下一组 assigned；无下一组时 Court.waiting_opponent
- failure result: 原比分和 awaiting_rotation 状态保持不变
- recovery path: 修正比分、补充等待组或选择 all_rotate
- owner: PlaySession
- required test assertion: 败方不能在同一次轮转中立即重新上场

### Runtime Action: resolve_rotation_all_rotate

- action_id: resolve_rotation_all_rotate
- actor: LocalOrganizer
- initiation: 从 awaiting_rotation 场地选择两组下场
- source state: Match.result_recorded；Court.awaiting_rotation；两组 PairingGroup.awaiting_rotation
- target entity: Match, Court, PairingGroup queue
- preconditions: 比分已保存
- input fields: matchId
- boundary checks: 本轮刚下场两组不能作为本轮新上场组；新比赛必须有两组既有 waiting
- state transition: 两组 awaiting_rotation -> waiting 队尾；原 Match -> completed
- success result: 有两组既有 waiting 时创建下一 Match.ready；不足时 Court.available
- failure result: 原比分和 awaiting_rotation 状态保持不变
- recovery path: 调整候场组、补充组或重试
- owner: PlaySession
- required test assertion: 两组下场模式不得创建含刚下场组的即时重赛

### Runtime Action: fill_staying_court

- action_id: fill_staying_court
- actor: LocalOrganizer
- initiation: 新等待组可用后为等待对手的场地补位
- source state: Court.waiting_opponent；PairingGroup.staying；PairingGroup.waiting
- target entity: Court, Match, PairingGroup
- preconditions: 场地恰有一组 staying
- input fields: courtId, optional selectedGroupId
- boundary checks: 补位组必须 waiting 且不等于上一场刚下场组
- state transition: staying + waiting -> assigned；Court.waiting_opponent -> ready；none -> Match.ready
- success result: 具象化场地更新为下一场对阵
- failure result: 场地继续等待对手
- recovery path: 新增或恢复玩家、完成组队或选择其他等待组
- owner: PlaySession
- required test assertion: waiting_opponent 场地只能保留一组 staying

### Runtime Action: release_staying_court

- action_id: release_staying_court
- actor: LocalOrganizer
- initiation: 不再等待新对手时清空留场场地
- source state: Court.waiting_opponent；PairingGroup.staying
- target entity: Court, PairingGroup queue
- preconditions: 场地恰有一组 staying 且没有当前 Match
- input fields: courtId, confirmation
- boundary checks: 必须确认；只能释放该场地关联的 staying 组
- state transition: PairingGroup.staying -> waiting 队尾；Court.waiting_opponent -> available
- success result: 场地回到可分配状态，留场组回到常规候场队列
- failure result: 场地和组保持原状态
- recovery path: 取消、等待补位或重试
- owner: PlaySession
- required test assertion: 释放动作必须同时清除 staying 引用并恢复唯一 queueOrder

### Runtime Action: cancel_match

- action_id: cancel_match
- actor: LocalOrganizer
- initiation: 从 ready 或 in_progress 场地发起取消
- source state: Match.ready / in_progress
- target entity: Match
- preconditions: 球局 active
- input fields: matchId, confirmation
- boundary checks: 必须确认；result_recorded / completed 比赛不能使用取消动作
- state transition: Match.current -> canceled；Court.ready / in_play -> available；两组 assigned / playing -> waiting
- success result: 比赛不计统计，两组按取消前相对顺序回到候场队首
- failure result: 取消确认时状态不变
- recovery path: 继续比赛或确认取消
- owner: Match
- required test assertion: canceled 比赛不得增加任何玩家或组统计

### Runtime Action: correct_completed_match

- action_id: correct_completed_match
- actor: LocalOrganizer
- initiation: 从比赛历史修正已完成结果
- source state: Match.completed
- target entity: Match
- preconditions: 所属球局未删除
- input fields: resultMode, winnerSide, optional gameScores, confirmation
- boundary checks: 新结果满足比分规则；必须确认统计将重算且历史轮转不会自动回滚
- state transition: Match.completed -> Match.completed
- success result: 替换结果并从全部 completed 比赛重算统计
- failure result: 保留原结果和统计
- recovery path: 修正输入或取消
- owner: Match
- required test assertion: 修正比分会重算统计，但不会改变后续 Match 的既有组和场地

### Runtime Action: complete_session

- action_id: complete_session
- actor: LocalOrganizer
- initiation: 从现场球局面发起结束
- source state: PlaySession.active
- target entity: PlaySession
- preconditions: 不存在 ready / in_progress / result_recorded Match，以及 awaiting_rotation / waiting_opponent Court
- input fields: sessionId, confirmation
- boundary checks: 必须确认；staying 组需先回到 waiting 或明确结束其场地等待
- state transition: PlaySession.active -> completed；全部非删除玩家和组 -> archived
- success result: 冻结运行动作并生成最终总结
- failure result: 球局保持 active
- recovery path: 完成、取消或解决所有当前场地
- owner: PlaySession
- required test assertion: 有未决比分或轮转时不能结束球局

### Runtime Action: duplicate_session_setup

- action_id: duplicate_session_setup
- actor: LocalOrganizer
- initiation: 从历史球局选择再次组织
- source state: PlaySession.completed / active
- target entity: PlaySession
- preconditions: 来源球局可读
- input fields: sourceSessionId, newTitle
- boundary checks: 只复制配置、场地名称和未删除玩家姓名；不复制组、队列、比赛和统计
- state transition: none -> PlaySession.draft
- success result: 创建独立的新球局草稿
- failure result: 不创建不完整副本
- recovery path: 修改标题或手动新建
- owner: PlaySession
- required test assertion: 新球局玩家均 ungrouped，场地均 available，比赛和组为空

### Runtime Action: delete_session

- action_id: delete_session
- actor: LocalOrganizer
- initiation: 从草稿、进行中或历史球局发起永久删除
- source state: PlaySession.draft / active / completed
- target entity: PlaySession
- preconditions: 球局存在
- input fields: sessionId, confirmation
- boundary checks: 必须二次确认；active 球局提示全部现场状态将删除
- state transition: PlaySession.current -> deleted
- success result: 删除球局及其玩家、组、场地、比赛和派生统计
- failure result: 取消或删除失败时保留全部数据
- recovery path: 取消、先完成球局或重试
- owner: PlaySession
- required test assertion: 删除失败不能留下孤立玩家、组、场地或比赛

## 8. State Machine

### Entity: PlaySession

- from: none
  event/action: create_session
  guard condition: 设置有效且本地可写
  to: draft
  actor: LocalOrganizer
  side effects: 创建空玩家、组、场地和比赛集合
  reversible: yes

- from: draft
  event/action: start_session
  guard condition: 至少四名 eligible 玩家、两组 waiting 和一块 available 场地
  to: active
  actor: LocalOrganizer
  side effects: 冻结比分预设并允许场地分配
  reversible: no

- from: active
  event/action: complete_session
  guard condition: 不存在未完成比赛、未决轮转或 waiting_opponent 场地
  to: completed
  actor: LocalOrganizer
  side effects: 生成最终摘要并禁用现场动作
  reversible: no

- from: draft / active / completed
  event/action: delete_session
  guard condition: 已确认永久删除
  to: deleted
  actor: LocalOrganizer
  side effects: 删除所属运行数据
  reversible: no

blocked operations per state:

- draft: 不能开始比赛、录入比分或轮转。
- active: 不能修改比分预设；允许添加玩家和场地，但受当前状态约束。
- completed: 不能组队、排序、分配或开始比赛；允许修正历史结果和复制设置。
- deleted: 禁止全部动作。

terminal states: completed, deleted。

### Entity: SessionPlayer

- from: none
  event/action: add_session_player / batch_add_session_players
  guard condition: 名称有效且容量允许
  to: ungrouped
  actor: LocalOrganizer
  side effects: 进入可组队池
  reversible: yes

- from: ungrouped
  event/action: create_manual_group / generate_random_groups
  guard condition: 与另一名不同且未成组玩家配对
  to: grouped
  actor: LocalOrganizer
  side effects: 关联一个有效 PairingGroup
  reversible: yes

- from: grouped
  event/action: dissolve_waiting_group / update_waiting_group
  guard condition: 所属组为 waiting
  to: ungrouped / grouped
  actor: LocalOrganizer
  side effects: 释放或替换组成员引用
  reversible: yes

- from: ungrouped
  event/action: set_player_resting
  guard condition: 不属于有效组
  to: resting
  actor: LocalOrganizer
  side effects: 退出可组队池
  reversible: yes

- from: ungrouped / resting
  event/action: set_player_left
  guard condition: 不属于有效组
  to: left
  actor: LocalOrganizer
  side effects: 退出后续球局但保留历史
  reversible: yes

- from: resting / left
  event/action: restore_player_eligible
  guard condition: 球局 active
  to: ungrouped
  actor: LocalOrganizer
  side effects: 返回可组队池
  reversible: yes

- from: ungrouped / grouped / resting / left
  event/action: complete_session
  guard condition: 球局可完成
  to: archived
  actor: LocalOrganizer
  side effects: 冻结身份与统计
  reversible: no

blocked operations per state:

- grouped: 不能加入第二个组；所属组非 waiting 时不能改名、休息、离场或删除。
- archived: 只读。

terminal states: archived, deleted。

### Entity: PairingGroup

- from: none
  event/action: create_manual_group / generate_random_groups
  guard condition: 两名唯一 eligible ungrouped 玩家
  to: waiting
  actor: LocalOrganizer
  side effects: 两名玩家变为 grouped，并取得 queueOrder
  reversible: yes

- from: waiting
  event/action: assign_next_groups_to_court / assign_specific_groups_to_court
  guard condition: 组未被其他场地占用
  to: assigned
  actor: LocalOrganizer
  side effects: 从候场队列暂时移除并关联 Match.ready
  reversible: yes

- from: assigned
  event/action: start_match
  guard condition: 所属 Match.ready 且场地一致
  to: playing
  actor: LocalOrganizer
  side effects: 锁定成员
  reversible: no

- from: playing
  event/action: record_match_result
  guard condition: 结果有效
  to: awaiting_rotation
  actor: LocalOrganizer
  side effects: 保留场地关联并等待上下场决策
  reversible: no

- from: awaiting_rotation
  event/action: resolve_rotation_winner_stays
  guard condition: 有唯一胜方
  to: assigned / staying / waiting
  actor: LocalOrganizer
  side effects: 有补位组时胜方直接进入下一 Match.ready；否则胜方 staying；败方进入队尾
  reversible: before next_match_starts

- from: awaiting_rotation
  event/action: resolve_rotation_all_rotate
  guard condition: 比分已保存
  to: waiting
  actor: LocalOrganizer
  side effects: 两组按稳定顺序进入队尾
  reversible: before next_match_starts

- from: staying
  event/action: fill_staying_court
  guard condition: 有另一组 waiting
  to: assigned
  actor: LocalOrganizer
  side effects: 与补位组创建下一 Match.ready
  reversible: yes

- from: staying
  event/action: release_staying_court
  guard condition: 已确认且所属 Court.waiting_opponent
  to: waiting
  actor: LocalOrganizer
  side effects: 进入候场队尾并释放场地
  reversible: no

- from: waiting
  event/action: dissolve_waiting_group
  guard condition: 已确认
  to: dissolved
  actor: LocalOrganizer
  side effects: 两名成员回到 ungrouped
  reversible: no

- from: assigned / playing
  event/action: cancel_match
  guard condition: 当前场地动作可取消
  to: waiting
  actor: LocalOrganizer
  side effects: 恢复组候场位置
  reversible: yes

- from: waiting
  event/action: complete_session
  guard condition: 球局不存在未决场地状态
  to: archived
  actor: LocalOrganizer
  side effects: 冻结组身份和派生统计
  reversible: no

blocked operations per state:

- assigned / playing / awaiting_rotation / staying: 不能换人、解散、手动排序或分配到其他场地。
- dissolved / archived: 禁止现场动作。

terminal states: dissolved, archived。

### Entity: Match

- from: none
  event/action: assign_next_groups_to_court / assign_specific_groups_to_court / fill_staying_court
  guard condition: 两组唯一且场地可承载新比赛
  to: ready
  actor: LocalOrganizer
  side effects: 两组 assigned，Court.ready
  reversible: yes

- from: ready
  event/action: start_match
  guard condition: 参赛 side 人数与 matchFormat 一致且场地状态一致
  to: in_progress
  actor: LocalOrganizer
  side effects: 两组 playing，Court.in_play
  reversible: no

- from: ready / in_progress
  event/action: cancel_match
  guard condition: 已确认且未保存结果
  to: canceled
  actor: LocalOrganizer
  side effects: 释放场地并让两组回队
  reversible: no

- from: in_progress
  event/action: record_match_result
  guard condition: 结果有效且唯一胜方可确定
  to: result_recorded
  actor: LocalOrganizer
  side effects: Court.awaiting_rotation，两组 awaiting_rotation
  reversible: yes

- from: result_recorded
  event/action: resolve_rotation_winner_stays / resolve_rotation_all_rotate
  guard condition: 轮转选择有效
  to: completed
  actor: LocalOrganizer
  side effects: 更新组队列和下一场
  reversible: before next_match_starts

- from: completed
  event/action: correct_completed_match
  guard condition: 新结果有效且已确认
  to: completed
  actor: LocalOrganizer
  side effects: 重算统计，不自动回滚历史轮转
  reversible: yes

terminal states: completed, canceled。

### Entity: Court

- from: none
  event/action: add_court
  guard condition: 名称唯一且容量允许
  to: available
  actor: LocalOrganizer
  side effects: 加入球局场地集合
  reversible: yes

- from: available
  event/action: assign_next_groups_to_court / assign_specific_groups_to_court
  guard condition: 有两组完整 waiting
  to: ready
  actor: LocalOrganizer
  side effects: 关联 Match.ready
  reversible: yes

- from: ready
  event/action: start_match
  guard condition: 关联 Match.ready
  to: in_play
  actor: LocalOrganizer
  side effects: 锁定当前对阵
  reversible: no

- from: in_play
  event/action: record_match_result
  guard condition: 结果有效
  to: awaiting_rotation
  actor: LocalOrganizer
  side effects: 保留当前对阵和比分，等待上下场决策
  reversible: no

- from: awaiting_rotation
  event/action: resolve_rotation_winner_stays
  guard condition: 结果有唯一胜方
  to: ready / waiting_opponent
  actor: LocalOrganizer
  side effects: 生成下一场或保留胜方等待补位
  reversible: before next_match_starts

- from: awaiting_rotation
  event/action: resolve_rotation_all_rotate
  guard condition: 比分已保存
  to: ready / available
  actor: LocalOrganizer
  side effects: 生成下一场或清空场地
  reversible: before next_match_starts

- from: waiting_opponent
  event/action: fill_staying_court
  guard condition: 有一组 waiting
  to: ready
  actor: LocalOrganizer
  side effects: 关联下一 Match.ready
  reversible: yes

- from: waiting_opponent
  event/action: release_staying_court
  guard condition: 已确认且场地只有一组 staying
  to: available
  actor: LocalOrganizer
  side effects: 留场组进入候场队尾，清除 staying 引用
  reversible: no

- from: ready / in_play
  event/action: cancel_match
  guard condition: 已确认且未保存结果
  to: available
  actor: LocalOrganizer
  side effects: 清除当前 Match 引用
  reversible: yes

terminal states: deleted；Court 生命周期跟随 PlaySession。

## 9. Boundary Check Matrix

### Boundary Check: session_input

- action_id: create_session / update_session_setup
- check_type: input
- condition: title 非空，比分和默认轮转枚举受支持
- block result: 不创建或不修改，原状态保持
- feedback: 指出具体无效字段
- recovery path: 修改字段后重试
- verification assertion: 空标题和非法枚举均被拒绝

### Boundary Check: session_start_readiness

- action_id: start_session
- check_type: state
- condition: 至少四名 eligible 玩家、两组完整 waiting、一块 available 场地，且设置有效
- block result: PlaySession 保持 draft，不创建 Match
- feedback: 分别说明缺少玩家、组、场地或无效设置
- recovery path: 补齐对应条件后重试
- verification assertion: 任一启动条件缺失时都不能进入 active

### Boundary Check: player_identity

- action_id: add_session_player / batch_add_session_players / update_session_player
- check_type: duplicate
- condition: 规范化名称在同一球局唯一且总人数不超过 64
- block result: 单条不写入；批量容量失败时整批不写入
- feedback: 显示重名或容量原因
- recovery path: 改名、减少名单或移除无用玩家
- verification assertion: 大小写或空白规范化后仍能识别重复

### Boundary Check: group_membership

- action_id: generate_random_groups / create_manual_group / update_waiting_group / dissolve_waiting_group
- check_type: ownership
- condition: 每个有效 PairingGroup 恰有两名唯一玩家，每名玩家最多属于一个有效组
- block result: 玩家、组和队列保持不变
- feedback: 指出已成组或不可用玩家
- recovery path: 选择其他玩家、解散等待组或等待比赛完成
- verification assertion: 任意时刻有效组成员集合无重复 playerId

### Boundary Check: group_edit_state

- action_id: update_waiting_group / dissolve_waiting_group / randomize_group_queue / reorder_waiting_group
- check_type: state
- condition: 只有 waiting 组可换人、解散和排序
- block result: 组、场地和比赛保持不变
- feedback: 说明该组已分配、比赛中或待轮转
- recovery path: 取消分配或完成场地流转后重试
- verification assertion: assigned / playing / awaiting_rotation / staying 不能绕过锁定

### Boundary Check: court_identity_and_capacity

- action_id: create_session / duplicate_session
- check_type: capacity
- condition: 新球局始终只创建一块场地
- block result: 不产生第二块新场地
- feedback: V1 固定使用一块场地
- recovery path: 不适用；旧多场地仅兼容读取
- verification assertion: 新建和复制后 Court 数量均为 1

### Boundary Check: assignment_uniqueness

- action_id: assign_next_groups_to_court / assign_specific_groups_to_court / fill_staying_court
- check_type: ownership
- condition: 每组最多属于一个 ready / in_progress / result_recorded Match
- block result: 不提交任何冲突分配
- feedback: 指出冲突组和场地
- recovery path: 选择其他组或取消原分配
- verification assertion: 单场地连续分配后参与单位无重复 ID

### Boundary Check: assignment_capacity

- action_id: assign_next_groups_to_court / assign_specific_groups_to_court
- check_type: capacity
- condition: 每场必须有两组、四名唯一玩家和一块 available 场地
- block result: 不创建残缺 Match
- feedback: 显示缺少的等待组数量
- recovery path: 完成组队、恢复玩家或等待其他场地轮转
- verification assertion: 只有一组 waiting 时场地保持 available

### Boundary Check: match_start_consistency

- action_id: start_match
- check_type: state
- condition: Match.ready、Court.ready、两组 assigned 和四名 grouped 玩家相互一致
- block result: 所有状态保持不变
- feedback: 提示具体冲突，需要重新分配
- recovery path: 取消异常比赛并重新分配
- verification assertion: 任一组或玩家引用异常时不能部分开赛

### Boundary Check: result_validity

- action_id: record_match_result / correct_completed_match
- check_type: input
- condition: winner_only 有唯一胜方；game_scores 满足比分预设并推导唯一胜方
- block result: 比赛、场地、组队列和统计保持原值
- feedback: 指出缺少胜方、平局、局数或终局分数错误
- recovery path: 修正后重新提交
- verification assertion: standard_21 的 21:20 和 31:29 无效，22:20 与 30:29 有效

### Boundary Check: rotation_exclusion

- action_id: resolve_rotation_winner_stays / resolve_rotation_all_rotate
- check_type: timing
- condition: 本轮刚下场组不属于本次补位候选；补位只从轮转动作开始前的 waiting 集合读取
- block result: 不创建下一 Match，保留 awaiting_rotation
- feedback: 说明暂无符合条件的下一组
- recovery path: 增加候场单位，或接受场地进入等待状态
- verification assertion: 刚下场组不得在同一次轮转中立即重赛

### Boundary Check: rotation_atomicity

- action_id: resolve_rotation_winner_stays / resolve_rotation_all_rotate / fill_staying_court / release_staying_court
- check_type: state
- condition: Match、Court、两组、候场队列和下一 Match 必须在同一原子动作中更新
- block result: 任一写入失败时全部回滚
- feedback: 说明轮转未生效，可重试
- recovery path: 重新读取当前场地并重试
- verification assertion: 不允许出现 Match.completed 但组仍 awaiting_rotation 的半状态

### Boundary Check: destructive_actions

- action_id: remove_session_player / remove_court / dissolve_waiting_group / release_staying_court / cancel_match / complete_session / delete_session
- check_type: destructive
- condition: 用户确认且目标处于动作允许状态
- block result: 取消或失败时所有 owner 保持原值
- feedback: 说明影响范围和不可恢复内容
- recovery path: 取消、处理状态冲突或重试
- verification assertion: 未确认不得改变任何所属对象

## 10. Data Ownership Matrix

### Data Ownership: PlaySession

- owner entity: PlaySession
- owned data: 球局配置、玩家、双人组、组候场顺序、场地、比赛和随机种子序列
- allowed mutations: 全部球局、玩家、组队、排序、分配、轮转、完成和删除动作
- derived state: 可组队人数、等待组数、可用场地数、球局摘要和全部统计
- forbidden owner leakage: Surface 不得自行维护另一份组队列、场地占用或轮转结果
- required test assertion: 重启恢复后组身份、queueOrder、场地和未决轮转与保存前一致

### Data Ownership: SessionPlayer

- owner entity: PlaySession owns SessionPlayer
- owned data: 本场身份、显示名和参与资格状态
- allowed mutations: 添加、改名、休息、恢复、离场、删除和组成员联动
- derived state: 当前组、场地状态、完成场次、胜负和得失分来自 PairingGroup 与 Match
- forbidden owner leakage: 玩家列表不能直接修改组状态、场地或统计
- required test assertion: 玩家当前是否上场必须能从有效组和场地关系唯一推导

### Data Ownership: PairingGroup

- owner entity: PlaySession owns PairingGroup
- owned data: 两名成员、当前状态、queueOrder、当前场地引用和创建方式
- allowed mutations: 随机创建、手动创建、等待时换人、解散、排序、分配和轮转
- derived state: 当前对手、完成场次、胜负和得失分来自 completed Match
- forbidden owner leakage: Match 不能私自创建第二份成员列表；队列面不能改变比赛中的组
- required test assertion: 任一非 dissolved 组始终恰有两名唯一玩家

### Data Ownership: Match

- owner entity: PlaySession owns Match
- owned data: 场地快照、两组及四名玩家快照、状态、结果和轮转方式
- allowed mutations: 生成、开始、结果录入、取消、轮转完成和结果修正
- derived state: 胜方、是否计入统计、每方得失分
- forbidden owner leakage: 场地展示层不得直接改比分；统计面不得直接改 Match
- required test assertion: canceled Match 永远不进入统计，result_recorded 未轮转时不能被当作现场已闭合

### Data Ownership: Court

- owner entity: PlaySession owns Court
- owned data: 场地身份、显示名、状态、当前 Match 和 staying Group 引用
- allowed mutations: 添加、移除、分配、开始、录分、轮转、补位和取消
- derived state: 当前两组、四名玩家、比分和下一动作均来自关联对象
- forbidden owner leakage: Court 不能脱离 Match 与 PairingGroup 独立切换占用状态
- required test assertion: 每个 ready / in_play / awaiting_rotation / waiting_opponent Court 都有唯一可解释的关联状态

## 11. Permissions

- `LocalOrganizer` 拥有当前设备内全部球局动作权限。
- V1 不存在球员自助操作、只读观众、共同组织者或远端管理员。
- 系统文件权限不是主链路依赖；V1 不要求相册、相机、麦克风、定位、通讯录或蓝牙权限。
- 删除球局、移除场地、解散组、取消比赛、修正结果和完成球局必须由明确用户动作发起。

## 12. Lifecycle

### App Launch

- 优先恢复最近一场 `active` 球局入口，但不自动组队、排序、分配、开始、录分或轮转。
- 没有 active 球局时进入球局历史和新建入口。

### Persistence

- 每个成功动作完成后立即持久化 owner 状态。
- 跨实体动作必须原子保存，尤其是比分后轮转和下一场创建。
- 派生统计可重建，不作为唯一事实来源。

### Background And Termination

- App 进入后台不改变比赛、场地、组或队列状态。
- V1 不依赖后台计时、后台通知或持续任务。
- 被系统终止后从最后一次成功动作恢复，包括 `awaiting_rotation` 和 `waiting_opponent`。

### Completion And Deletion

- `completed` 球局保留历史、统计和结果修正能力，但不能继续组队、排序、分配或轮转。
- `deleted` 为不可恢复终态。
- V1 不做自动归档、自动过期或云端备份。

## 13. Failure / Recovery Matrix

| failure | affected action | state after failure | user feedback | recovery |
| --- | --- | --- | --- | --- |
| 本地存储不可写 | 任一写动作 | 所有 owner 保持旧状态 | 说明保存失败 | 释放空间后重试 |
| 批量名单有空行或重名 | batch_add_session_players | 容量允许时写入唯一有效项 | 报告跳过数量 | 修改名单后补充 |
| 随机组队人数为奇数 | generate_random_groups | 最后一人保持 ungrouped | 说明未成组玩家 | 新增玩家或手动调整 |
| 玩家已属于有效组 | create_manual_group / generate_random_groups | 玩家和组集合不变 | 指出冲突组 | 解散等待组或换人 |
| 试图修改场上组 | update_waiting_group / dissolve_waiting_group | 组、场地和比赛不变 | 说明组已锁定 | 完成或取消当前场地流转 |
| 候场组不足两组 | assign_next_groups_to_court | 不创建 Match | 说明缺少组数 | 完成组队或等待其他场地 |
| 场地被占用 | assign_specific_groups_to_court | 不改变场地 | 说明当前状态 | 选择其他场地或完成当前比赛 |
| 比分无效 | record_match_result | Match.in_progress，Court.in_play | 指出具体错误 | 修正后重新提交 |
| 胜方留场但无下一组 | resolve_rotation_winner_stays | Court.waiting_opponent，胜方 staying | 说明等待下一组 | 新增组或从等待组补位 |
| 不再等待留场补位 | release_staying_court | 成功时 Court.available、原胜方 waiting | 说明该组回到队尾 | 重新分配场地或继续候场 |
| 两组下场但候场不足两组 | resolve_rotation_all_rotate | Court.available，两组进入队尾 | 说明暂无下一场 | 等待或重新排序后分配 |
| 轮转写入失败 | 任一 resolve_rotation | 保持 result_recorded / awaiting_rotation | 说明未完成轮转 | 重新读取场地并重试 |
| 误取消比赛 | cancel_match | 确认前不改变 | 显示取消影响 | 返回比赛或确认取消 |
| 比分修正改变历史胜方 | correct_completed_match | 统计重算，历史轮转不回滚 | 明确影响范围 | 手动修正后续现场状态（如仍 active） |
| 结束时有未决轮转 | complete_session | PlaySession.active | 列出未处理场地 | 完成或取消所有场地动作 |
| App 被终止 | 任一 active 流程 | 恢复最后一次成功快照 | 提供继续入口 | 检查现场后继续 |
| 永久删除失败 | delete_session | 保留完整球局 | 说明删除失败 | 重试，不做部分清理 |

## 14. Runtime Surface Responsibilities

### SessionLibrary

- entry source: App 启动或从其他球局返回。
- responsibilities: 展示草稿、进行中和已完成球局；发起新建、复制和删除；优先暴露未完成球局。
- exit/back: 退出 App 不改变球局状态。
- empty state: 允许创建第一场球局，不展示伪造数据。
- readonly state: 已完成球局可查看和复制。
- error state: 读取失败时不能以空列表覆盖本地数据。
- destructive confirmation: 承担 delete_session 确认。

### SessionSetup

- entry source: 新建草稿或打开已有 draft。
- responsibilities: 编辑核心配置；添加玩家和场地；校验启动条件。
- exit/back: 返回保留已成功保存的草稿。
- empty state: 明确至少需要四名可组队玩家、两组和一块场地。
- readonly state: active / completed 不能修改冻结配置。
- error state: 保存失败时保留本地编辑上下文并显示重试。
- destructive confirmation: 承担移除玩家和场地确认。

### GroupingWorkspace

- entry source: draft 或 active 球局的分组入口。
- responsibilities: 展示未成组玩家和持续双人组；发起随机组队、手动组队、等待组换人和解散。
- exit/back: 返回不自动改变组和候场顺序。
- empty state: 少于两名未成组玩家时说明无法继续成组。
- readonly state: 场上和待轮转组只读。
- error state: 成员冲突时阻止写入并指出冲突组。
- destructive confirmation: 承担 dissolve_waiting_group 确认。

### RotationWorkspace

- entry source: active 球局的轮转入口。
- responsibilities: 展示 PairingGroup.waiting 的稳定顺序；发起随机排序和手动排序；显示 staying 组和等待对手场地。
- exit/back: 返回不改变队列。
- empty state: 无 waiting 组时说明哪些组正在场地或仍未组队。
- readonly state: assigned / playing / awaiting_rotation / staying 不能排序。
- error state: 排序冲突时重新读取 owner 队列，不保留另一份 UI 顺序。
- destructive confirmation: 随机重排前说明将改变后续上场顺序。

### CourtWorkspace

- entry source: active 球局默认直接进入。
- responsibilities: 以具象化羽毛球场作为唯一主工作区，展示当前参赛者、比赛状态和唯一下一动作；发起手动分配、开赛、合并结算、补位和取消。球友、候场顺序和比赛记录通过上下文工具进入，不与主工作区并列为底部导航。
- object renderer: 必须保留标准羽毛球场空间关系，两组位于球网两侧，每组两名玩家落在可辨识位置；比分和轮转动作依附具体场地，不退化成仅含 A/B 文本的普通信息卡。
- reference: `docs/work/icon_library/rally-pair-icon-palette-preview.html` 中已确认的具象化场地是语义基线；最终 Flutter 结构可适配尺寸，但不得丢失球场、站位和场地状态关系。
- exit/back: 返回不暂停、不取消任何比赛或轮转。
- empty state: 空闲场地仍显示具象场地，并提供分配两组的入口。
- readonly state: completed 球局转入总结，不继续操作现场。
- error state: 跨实体不一致时阻止继续，并提供取消异常比赛或重新读取路径。
- destructive confirmation: 承担取消比赛和结束现场状态确认。

### MatchResultEntry

- entry source: 从 Court.in_play 发起结果录入，或从 Match.completed 发起修正。
- responsibilities: 当前比赛结算时只选择 winner_only / game_scores，提交后由 PlaySession 自动应用球局轮换规则；历史修正只修改结果和统计，不回滚轮转。
- exit/back: 未提交时 Match 和 Court 保持原状态。
- empty state: 不允许无胜方或空局分提交。
- readonly state: canceled Match 不可进入。
- error state: 显示具体局分错误，不进入 awaiting_rotation。
- destructive confirmation: 修正 completed 结果时说明统计重算且历史轮转不回滚。

### RotationExecution

- entry source: Match.result_recorded / Court.awaiting_rotation。
- responsibilities: PlaySession 读取开局前保存的 defaultRotationMode，自动完成留场、下场和下一组安排；旧恢复状态只允许按球局规则继续。
- exit/back: 正常结算不暴露独立轮换表面；旧恢复状态未继续时保持 awaiting_rotation。
- empty state: 候场不足时显示将进入 waiting_opponent 或 available 的结果。
- readonly state: 下一 Match.in_progress 后不得撤销上一轮转。
- error state: 原子写入失败时完整保留未决轮转。
- destructive confirmation: 不提供单场重做轮转；历史结果纠错不回滚已执行轮转。

### SessionSummary

- entry source: complete_session 或历史球局。
- responsibilities: 优先展示完成场数、上场覆盖、人均出场和轮转均衡提示；只对实际上场球友展示出场、胜负、胜率、常搭档与可靠净胜分；未上场球友独立说明；比赛记录默认降权展开，并保留单场结果修正。
- exit/back: 不改变结果。
- empty state: 无 completed 比赛时显示“本场未产生有效比赛”，仍允许保留球局。
- readonly state: 不提供继续组队、排场或轮转。
- error state: 统计重建失败时优先展示原始比赛并阻止错误摘要覆盖。
- destructive confirmation: 不直接承担整场删除，返回 SessionLibrary 处理。

## 15. Domain Entities

```text
PlaySession hasMany SessionPlayer
PlaySession hasMany PairingGroup
PlaySession hasMany Court
PlaySession hasMany Match
PairingGroup hasExactlyTwo SessionPlayer references
Match belongsTo PlaySession
Match belongsTo Court
Match hasExactlyTwo PairingGroup snapshots
Court hasZeroOrOne current Match
Court hasZeroOrOne staying PairingGroup
Court hasZeroOrOne staying SessionPlayer
PlaySession derives PlayerSummary and GroupSummary from completed Match collection
```

概念约束：

- `PlaySession` 是唯一聚合根。
- `SessionPlayer` 仅在一场球局内有效，不等同于全局账号。
- `PairingGroup` 是双打中跨多轮持续存在的双人组，不是 Match 内的临时 `Team` 值；单打不创建组。
- `Match` 保存两个 side 的当场快照；单打每 side 一人，双打每 side 两人。
- `Court` 是具象化现场场地，承载当前 Match、比分上下文和轮转状态，但不代表真实场馆数据。
- `PlayerSummary` 和 `GroupSummary` 是派生结果，不是可编辑实体。

## 16. Runtime Boundaries

### Pairing Mode

- `random_pairing`: 仅对 eligible ungrouped 玩家洗牌后两两成组；奇数剩余玩家保持 ungrouped。
- `manual_pairing`: 组织者明确选择两名 eligible ungrouped 玩家成组。
- 随机和手动组队可以在同一球局共存；已有 waiting 组不被随机动作自动拆散。
- 组创建后持续存在，只有 waiting 组允许换人或解散。
- V1 不按性别、水平、胜率或体力做自动权重。

### Queue Order Mode

- `random_order`: 仅随机打乱 waiting 组。
- `manual_order`: 组织者直接调整 waiting 组的稳定 queueOrder。
- 两种排序方式都不能影响 assigned、playing、awaiting_rotation 或 staying 组。
- 相同输入和相同随机种子必须得到可重复结果，方便测试和恢复。

### Rotation Mode

- `winner_stays`: 胜方留场，败方进入队尾，从轮转前 waiting 队首选择一组补位。
- `all_rotate`: 两组进入队尾，从轮转前 waiting 队首选择两组补位。
- 两种轮转方式均为 V1 必需能力；创建球局时必须选择一种，开局后整场自动执行。
- 本轮刚下场组不进入本轮补位候选，避免即时重赛。
- 没有足够补位组时不创建残缺 Match；场地进入 waiting_opponent 或 available。

### Court Interaction Representation

- 具象化场地是 CourtWorkspace 的核心业务表达，不是装饰背景。
- 唯一场地必须同时表达场地身份、参赛双方、比赛状态、比分和下一动作。
- 双方位于球网两侧；单打各一人居中，双打每侧两人保持稳定可辨识的位置。
- available、ready、in_play、awaiting_rotation、waiting_opponent 必须在同一场地对象上切换，不用多个互不关联的普通卡片替代。
- 新流程只呈现一块场地；旧多场地球局保持原对象用于兼容收尾。

### Score Preset

- `quick_11`: 一局定胜负，先到 11 分获胜，不启用加分延长。
- `standard_21`: 一局定胜负；21 分；20 平后领先 2 分获胜；30 分封顶。
- `winner_only`: 只保存胜方，不产生得失分。
- `game_scores`: 保存各局最终比分并派生胜方。
- V1 不跟踪逐球历史、发球权、局间换边和暂停。

### Statistics

- completedMatchCount 只统计 `Match.completed`。
- win / loss 只来自唯一胜方。
- pointsFor / pointsAgainst 只聚合 game_scores，winner_only 不伪造分数。
- 上场覆盖只统计至少参与一场 completed Match 的球友；人均出场按 completed Match 参赛人次除以本场球友总数。
- 球友胜率只在 completedMatches 大于零时展示；净胜分只在该球友全部 completed Match 都记录 game_scores 时展示。
- 本场表现排序只用于历史总结扫读，不等同于 MVP、竞技等级或跨球局能力评价。
- 玩家搭档关系来自 Match 的组快照；组统计按 PairingGroup 身份聚合。
- 结果修正后从 Match 集合全量重算。
- 结果修正不自动回滚已开始或已完成的后续轮转。

### Local-Only Boundary

- 不请求网络即可完成全部 V1 主链路。
- 不需要任何专用图片、音频或视频素材。
- 具象化球场使用代码或项目 SVG 绘制，不依赖外部场馆图片。
- 所有审核演示都能使用代码生成的虚构玩家、组和比赛完成。

## 17. Test Data And Fixture Plan

### Fixture Generation

- 使用固定种子 `20260722` 生成可重复玩家、组队和排序结果。
- 内置仅用于开发和截图构建的虚构名称池，不在正式空状态自动展示。
- 基础名称：林一、陈舟、周宁、苏禾、顾言、许川、沈青、唐远、江禾、陆宁、程野、夏言。
- 不使用真人照片、球拍品牌、场馆名称或网络数据。

### Required Fixtures

1. `empty_draft`: 0 名玩家、0 块场地。
2. `odd_players`: 5 名 ungrouped 玩家，随机组队后两组加一名 ungrouped。
3. `manual_groups`: 8 名玩家、4 个人工组、2 块 available 场地。
4. `random_group_queue`: 6 个 waiting 组，验证固定种子顺序。
5. `manual_group_queue`: 6 个 waiting 组，验证手动排序恢复。
6. `singles_ready_court`: 一块 Court.ready、2 名玩家 assigned。
7. `doubles_ready_court`: 一块 Court.ready、2 组 assigned。
8. `winner_stays_with_next`: 胜方留场且有下一组补位。
9. `winner_stays_without_next`: 胜方 staying，Court.waiting_opponent。
10. `all_rotate_with_two_next`: 两组下场且两组既有 waiting 上场。
11. `all_rotate_without_enough_next`: 两组下场后 Court.available。
12. `completed_session`: 混合两种轮转模式和合法比分。
13. `correction_after_rotation`: 修正历史胜方但后续 Match 阵容不回滚。

### Required Score Samples

- quick_11: 11:7。
- standard_21 single game: 21:15。
- valid cap: 30:29。
- invalid samples: 20:20, 21:20, 30:28, 31:29，以及任何多局输入。

### State Coverage

- 空状态：无球局、无玩家、无场地、无组、无等待组。
- 组队：随机、手动、奇数剩余、成员冲突、等待组换人和解散。
- 排序：随机顺序、手动顺序、场上组锁定和重启恢复。
- 场地：available、ready、in_play、awaiting_rotation、waiting_opponent。
- 轮转：winner_stays、all_rotate、候场充足和候场不足。
- 完成：正常完成、无有效比赛完成和未决轮转阻塞。
- 异常：重名、容量、跨场地重复组、比分无效、原子写入失败。
- 撤销与纠错：取消比赛、下一场前重做轮转、修正已完成结果。

## 18. Assumptions and Unknowns

### Assumption

- assumption: V1 在建局时选择单打或双打，active 后不允许切换。
- why low risk: 用户已明确确认单双打均需支持，且不做混合赛制球局。
- affected logic: 候场单位、场地分配、比赛、轮转和统计。
- validation needed: 分别使用单打 2–6 人和双打 4–12 人完成手工走查。

### Assumption

- assumption: 双人组创建后持续存在，直到组织者主动修改或解散 waiting 组。
- why low risk: 留场、下场和组候场顺序都要求组具有跨比赛身份。
- affected logic: PairingGroup、队列、Match 快照和统计。
- validation needed: 验证多轮后组身份和历史阵容保持一致。

### Assumption

- assumption: winner_stays 与 all_rotate 是球局级规则，active 状态不允许单场覆盖。
- why low risk: 用户明确要求把规则决策前移，避免每场结算重复打断。
- affected logic: SessionSetup、MatchResultEntry 和 RotationExecution。
- validation needed: 真实设备连续完成多场，确认轮换选择不再重复出现。

### Assumption

- assumption: 单设备组织者采用赛后结果录入，不逐球计分。
- why low risk: 一台设备无法同时可靠操作多块场地，赛后录入符合组织职责。
- affected logic: Match 状态和结果录入。
- validation needed: 原型阶段确认从结束比赛到轮转完成的操作足够短。

### Assumption

- assumption: 修正历史比分不自动回滚已经发生的上下场和后续比赛。
- why low risk: 自动回滚会破坏真实现场历史；比分统计和实际轮转应分别保留事实。
- affected logic: correct_completed_match、统计和历史解释。
- validation needed: 通过 correction_after_rotation fixture 验证提示和结果。

### Naming Decision

- decision: 中文正式名为“羽搭”，英文正式名为“RallyPair”，内部工程代号为 `rally_pair`。
- rationale: “羽搭”关联羽毛球搭档、分组和配合；“RallyPair”延续对局与搭档语义。
- rejected naming: “羽局 / RallyQueue”与“羽球局 / ShuttleRounds”均已于 2026-08-23 被否决。
- conflict screen: 既有命名筛选不替代正式商标与主体名称检索。
- affected action/state/boundary: 工程、应用显示名和商店物料统一使用本命名。

### Unknown

- unknown: V1 是否需要记录比赛耗时。
- affected action/state/boundary: 可能增加时间锚点和中断恢复逻辑。
- risk: 增加但不改变核心球局闭环。
- blocks readiness: no
- required clarification: 默认不进入 V1，后续单独评估。

## 19. Completed Launch-Blocking Work

### Completed: replace_legacy_runtime_model

- required item: 将当前个人候场、临时 Team 和四人统一回队模型替换为持续 PairingGroup、组队列和场地轮转模型
- why runtime-required: 当前实现无法表达用户已确认的核心上下场业务
- completion evidence: 领域模型、schema v5、存储往返和自动化测试已覆盖单双打与两种轮转
- delivered runtime flow: 单打个人队列、双打组队与组排序、winner_stays、all_rotate、waiting_opponent
- owner or required dependency: 后续 plan-spec / exec-spec / code-flow
- unblock condition: 新领域状态机、迁移策略和测试全部通过
- temporary workaround allowed: no

### Completed: implement_court_object_renderer

- required item: 以具象化羽毛球场按赛制呈现双方、比分和轮转状态
- why runtime-required: 场地是分配、比分和上下场决策的核心运行对象
- completion evidence: Flutter CourtWorkspace 已按单打两人 / 双打四人显示参赛位置和运行状态
- delivered runtime flow: 场地分配确认、单局比分、awaiting_rotation 和补位理解
- owner or required dependency: app-design / flutter-ui-production
- unblock condition: available、ready、in_play、awaiting_rotation、waiting_opponent 五类场地状态可在同一对象上验证
- temporary workaround allowed: no

后续发布前仍需在真实设备走查长名单、放大字体、比分弹窗和连续轮转手感。

## 20. Logic Completeness Validation

- Product Goal、角色、MVP 与 Non Goals 已按持续双人组和场地轮转修订。
- 主链路覆盖玩家、场地、随机/手动组队、随机/手动排序、场地分配、比分、两种轮转和完成。
- Runtime Required Feature 均映射到最小可执行动作。
- PlaySession、SessionPlayer、PairingGroup、Match 和 Court 均有状态机和 owner。
- 每个核心动作均有边界、失败结果、恢复路径和测试断言。
- 具象化场地被锁定为 CourtWorkspace 的核心对象表达，而非普通信息卡。
- 单场地、单双打候场不足、奇数双打玩家、未决轮转和历史比分修正均有恢复逻辑。
- 不存在 `blocks readiness: yes` 的 Unknown。

Logic Completeness Gate: PASS。

## 21. Requirement Logic Readiness

Verdict: `REQUIREMENT LOGIC READY`

本文与 2026-08-30 的单场地运行模型决策共同作为当前实现和后续迭代的产品基线。
