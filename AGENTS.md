# Project Instructions

## Documentation Governance

- 本项目默认使用 `docs-keeper` 管理项目文档。
- 新建、移动、整理、检查、迁移或归档 `docs/` 内容时，必须使用 `docs-keeper` skill 并遵循其路由、状态和验证规则。
- 处理文档前先阅读 `docs/status/current.md` 和 `docs/README.md`。
- 不在 `docs/` 根目录散放业务文档；过程稿、长期基线、外部资料、关键决策和历史归档必须进入对应标准分类。
- 修改文档后同步更新 `docs/status/current.md`，并在完成前运行 docs-keeper 检测。

## Product Baseline

- 产品规划、设计、执行规格和实现开始前，优先阅读 `docs/knowledge/product/badminton-session-organizer.md`。
- 新需求若与当前产品基线冲突，先明确影响与取舍，不直接并入 V1。

## Icon System Governance

- 本项目生成、修改、扩展或实现任何应用内图标前，必须先阅读并遵守 `docs/decisions/icon-library-visual-direction.md`。
- `docs/work/icon_library/rally-pair-icon-batch-01.html` 与其引用的 SVG 是当前规范的视觉样本；新图标必须与该批次保持同一图标家族感。
- 默认绘制约束固定为 `24×24` viewBox、`2.2px` 圆头圆角轮廓、主体位于 `3–21px` 安全区、大留白和单一局部实心强调。
- 默认使用 `#2563D9` 作为主体轮廓、`#3BBF75` 作为局部强调；绿色不得单独承担业务状态含义。
- 图标必须先检查真实 `24px` 效果；小尺寸下轮廓发糊、语义相似或细节拥挤时不得进入生产 assets。
- 未经用户明确确认，不得改成细线、尖角、拟物、复杂插画、纯单色填充或其他配色体系，也不得覆盖已确认的图标源文件。
- 如确需偏离规范，先说明原因和影响，取得确认后同步更新图标视觉决策、HTML 图标墙与 `docs/status/current.md`。
