# 单场地、单双打与一局比分运行模型决策

document_state: accepted
decision_date: 2026-08-30

## Decision

羽搭 V1 改为“单场地 + 球局级单双打 + 单局比分”模型：

- 新建与复制球局固定一个 Court。
- `MatchFormat.singles` 以个人为候场与轮转单位，每场两人。
- `MatchFormat.doubles` 以持续双人组为候场与轮转单位，每场两组四人。
- 两种赛制都支持 `winner_stays` 与 `all_rotate`。
- `quick_11` 与 `standard_21` 都只记录一个 GameScore。
- 旧多场地与旧多局比分数据仅用于兼容读取、收尾和历史查看。

## Locked Semantics

- matchFormat 在创建时必选，active 后冻结。
- draft 切换赛制必须清理不兼容的格式专属准备状态。
- singles 不创建 PairingGroup；doubles 不允许个人直接上场。
- 21 分仍遵守 20 平后净胜两分与 30 分封顶。
- 新流程不提供场地数量、添加场地或移除场地动作。

## Compatibility

- schema 缺少 matchFormat 的旧记录按 doubles 解释。
- 旧多场地 active 球局保持原 Court，不做破坏性裁剪。
- 旧多局比分继续可读和展示；新结果只允许单局。
- 复制旧球局时生成单场地新规则球局。

## Supersedes

本决策替代 [双人组、场地与上下场轮转运行模型决策](group-court-rotation-runtime-direction.md) 中以下部分：

- 多场地是 V1 required feature。
- 仅支持双打。
- standard_21 使用三局两胜。

旧决策关于 doubles 固定组、候场顺序和两种轮转的语义继续有效。

