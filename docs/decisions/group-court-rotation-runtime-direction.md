# 双人组、场地与上下场轮转运行模型决策

document_state: accepted
decision_date: 2026-08-27

## Decision

羽搭 V1 采用“持续双人组 + 组候场队列 + 具象化场地 + 分场地比分 + 赛后上下场轮转”的运行模型。

玩家先组成固定两人 `PairingGroup`，组再按候场顺序进入具体 `Court`。每场比赛结束并记录结果后，组织者必须选择一种轮转方式：

- `winner_stays`：胜方留场，败方进入候场队尾，从本轮开始前已经 waiting 的组中补一组。
- `all_rotate`：当前两组都进入候场队尾，从本轮开始前已经 waiting 的组中补两组。

若候场组不足，不创建残缺比赛。胜方留场时场地进入 `waiting_opponent`；两组下场时场地进入 `available`。

## Locked Product Semantics

### Grouping

- 随机组队与手动组队是两个独立入口。
- 每组固定两名玩家，组身份跨多场比赛持续存在。
- 随机组队只处理当前可用且未成组玩家；奇数剩余玩家保持未成组。
- 只有 waiting 组可以换人或解散。

### Queue Order

- 随机上场顺序与手动排序是两个独立入口。
- 排序只影响 waiting 组，不影响已分配、比赛中、待轮转或留场组。
- 同一组不能同时占用两块场地。

### Rotation

- 两种轮转方式都是 V1 必需能力，可设置球局默认值，也可在每场结算时覆盖。
- 本轮刚下场的组不能在同一次轮转中立即重新补位。
- 比分、原比赛完成、组队列、场地状态和下一场创建必须原子更新。
- `waiting_opponent` 场地可以补入新组，也可以释放留场组并恢复为空闲场地。

### Court UI

- Court 是现场流转的核心业务对象，不是普通比赛记录卡片。
- 场地必须以具象化羽毛球场呈现，保留球网两侧、两组和四名玩家的空间关系。
- 场地身份、当前比分、比赛状态和下一动作必须依附同一场地对象。
- [图标与配色 HTML 风格板](../work/icon_library/rally-pair-icon-palette-preview.html) 中已确认的具象化场地作为语义参考；Flutter 可以适配布局，但不得退化为仅含 A/B 文字的普通卡片。

## Superseded Direction

以下旧方向自本决策生效起不再作为 V1 实现或验收依据：

- 以个人为候场单位，每轮临时生成搭档。
- 以“公平轮转”算法直接选择四名玩家并拆分临时队伍。
- 比赛结束后四名玩家全部统一回到个人候场队列。
- 用普通 A/B 信息卡替代具象化场地状态。

旧代码和旧测试可以作为迁移输入，但不能证明新业务流已完成。

## Consequences

- 领域模型需要显式持久化 `PairingGroup`、组队列位置、Court 当前占用和未决轮转。
- 计划与执行规格需要覆盖旧本地数据的兼容或重建策略。
- 自动化测试必须覆盖随机/手动组队、随机/手动排序、多场地唯一占用、两种轮转、候场不足、恢复和原子失败。
- CourtWorkspace 的 UI 与交互需要围绕同一具象场地对象实现 available、ready、in_play、awaiting_rotation 和 waiting_opponent。

## Source Of Truth

完整动作、状态、边界、失败恢复和页面职责以 [羽搭 / RallyPair 产品方向基线](../knowledge/product/badminton-session-organizer.md) 为准。本决策用于冻结跨产品、设计、数据与实现阶段都必须遵守的方向。
