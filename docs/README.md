# 项目文档

doc_profile: docs-keeper

本目录使用 `docs-keeper` 管理。当前文档状态与阅读入口见
[`status/current.md`](status/current.md)。

## 目录约定

| 目录 | 用途 |
| --- | --- |
| `status/` | 当前状态与唯一阅读入口 |
| `work/{work_key}/` | 当前任务、功能或版本阶段的过程文档 |
| `knowledge/` | 已采纳、当前有效的长期项目基线 |
| `resources/` | 外部资料、接口资料、第三方资料与发布资料 |
| `decisions/` | 影响多个阶段或后续实现的关键决策 |
| `archive/` | 已过期但仍有追溯价值的摘要与少量原文例外 |

## 命名与维护

- `work_key` 使用稳定的英文 `snake_case`，例如 `account_onboarding`。
- Markdown 文件使用稳定的英文 `kebab-case`，避免 `latest`、`final`、`old`、`temp` 等漂移命名。
- 新增或调整文档后，同步更新 `status/current.md` 的状态与 Recent Changes。
- 只按需创建二级目录，不预建空的深层目录。
- 过期内容优先沉淀为摘要，不把 `archive/` 当作临时文件夹。

## 文档流转

1. 过程产物进入 `work/{work_key}/`。
2. 经确认采纳的长期结论沉淀到 `knowledge/`、`resources/` 或 `decisions/`。
3. 被替代且仍有追溯价值的内容摘要归档。
4. 每次文档变更后运行 docs-keeper 检查。

## Local Extensions

当前没有项目自定义文档分类。新增一级分类或非标准二级分类前，必须先确认并在此登记。
