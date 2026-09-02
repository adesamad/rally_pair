# 球局总结与球友表现信息优化

document_state: accepted_for_implementation
analysis_mode: feature-impact-analysis

## 1. Requested Change

结束球局后的“球友表现”不能只平铺胜负和模糊的得失分总和，需要让组织者快速看懂整场参与覆盖、轮转均衡和每名实际参赛球友的本场表现。

## 2. Product Outcome

总结页按以下阅读顺序回答三个问题：

1. 这场一共完成多少场，多少人真正上过场。
2. 实际参赛者各自打了多少场、胜负与胜率如何，完整比分可用时净胜分如何。
3. 需要核对或修正时，每场双方和比分是什么。

## 3. Feature Classification

- Runtime Support：展示完成场数、上场覆盖和人均出场。
- Runtime Support：只对至少完成一场比赛的球友展示表现数据。
- Runtime Support：单独列出未上场球友，避免用 `0 胜 0 负` 混入表现比较。
- Runtime Support：比赛记录保留双方、比分和修正入口，默认降为按需展开。
- Non Goal：不评选 MVP，不引入 Elo、竞技等级或跨球局能力评价。

## 4. Derived Statistics Contract

- `completedMatches` 只来自 `Match.completed`。
- 上场覆盖 = 至少参与一场 completed Match 的人数 / 本场球友总数。
- 人均出场 = completed Match 的参赛人次 / 本场球友总数；保留一位小数。
- 胜率 = wins / completedMatches；只对已上场球友展示。
- 净胜分只在该球友参与的所有 completed Match 都使用 `gameScores` 时展示。
- `winnerOnly` 不伪造得失分；存在未记比分场次时，不展示该球友的净胜分。
- 表现列表按胜率、胜场、出场数排序；这是本场记录的扫读顺序，不代表能力评级。

## 5. Surface Responsibility Changes

### SessionSummary

- 首屏由“人数 / 场地 / 完成”的静态档案改为“完成场数 / 上场覆盖 / 人均出场”的整场概览。
- 依据出场次数极差生成中性轮转提示；不把小样本包装成竞技结论。
- 球友表现仅展示已上场球友，并提供出场、胜负、胜率、常搭档与条件成立时的净胜分。
- 未上场球友进入独立低权重说明区。
- 比赛记录默认折叠；展开后展示双方、胜负或比分，并继续提供结果修正。

## 6. State And Recovery

- 有完成比赛：展示概览、表现、未上场说明和可展开比赛记录。
- 无完成比赛：明确没有可统计的表现，全部球友按未上场处理，比赛记录显示空态。
- 修正比赛结果：沿用原入口和确认逻辑；保存成功后重新计算全部页面派生信息。
- 读取失败：沿用重新读取恢复路径。

## 7. Ownership And Persistence

- `PlaySession`、`SessionMatch` 和 `PlayerStats` 继续作为事实来源。
- 页面只建立只读展示投影，不新增持久化字段、schema、权限、路由或远端依赖。
- 结果修正仍由 `PlaySession.correctMatch` 持有，UI 不直接修改统计。

## 8. Acceptance Checks

- 一场单打、六名球友时，概览显示 `2 / 6 人` 上场并单列四名未上场球友。
- 一场双打、四名球友时，四人均显示出场、胜负、胜率和完整比分对应的净胜分。
- 包含 `winnerOnly` 时，相关球友不显示伪造净胜分。
- 比赛记录默认折叠，展开后能看到双方并继续修正结果。
- 小样本页面不出现 MVP、最佳球员或能力评级文案。

## 9. Requirement Logic Readiness

`REQUIREMENT LOGIC READY`：本次只增加可靠派生信息并重排总结页呈现，不改变运行状态机或历史纠错语义。
