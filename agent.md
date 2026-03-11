# agent.md

## 1) 项目定位（先理解这个再动手）

这是一个 **Copier 模板仓库**，用于生成基于 Bazel + Aspect Workflows 的多语言 monorepo。  
你在这里改的多数文件不是“业务代码”，而是“未来新仓库的脚手架模板”。

- 模板入口说明：`README.md`
- 核心模板配置：`copier.yml`
- 生成模板文件目录：`template/`
- 初始化/更新任务封装：`init.axl`、`update.axl`
- 使用示例与用户故事：`user_stories/`

---

## 2) 目录速读（高频）

- `copier.yml`  
  定义 Copier 问题项、默认值、条件排除（`_exclude`）和后置任务（`_tasks`）。

- `template/`  
  真正会被复制到目标项目的文件。
  - `*.jinja`：Jinja 模板，生成时会去掉 `.jinja` 后缀。
  - 非 `.jinja` 文件：按原样复制。

- `template/README.bazel.md.jinja`  
  生成后项目的开发者指南模板，通常是开发命令和工作流的权威说明。

- `init.axl`  
  对 `copier copy --trust` 的封装，会尝试 `copier` / `pipx run copier` / `uvx copier`。

- `update.axl`  
  对 `copier update --trust` 的封装，要求当前目录存在 `.copier-answers.yml`。

---

## 3) 关键工作流（AI 改动时必须遵守）

1. **先判断改动层级**  
   - 改“模板行为” → 改 `copier.yml`、`template/`、`init.axl`、`update.axl`
   - 改“仓库文档” → 改根目录 `README.md`/`user_stories/` 等

2. **涉及新文件或语言能力时，联动检查**
   - `copier.yml` 的 `_exclude` 是否需要新增条件分支
   - `template/` 是否新增对应模板文件
   - `README.md` / `template/README.bazel.md.jinja` 是否要补说明

3. **保持模板可渲染**
   - 不要破坏 Jinja 语法（`{% ... %}`、`{{ ... }}`）
   - 变更条件分支时，确保“启用/禁用某语言”两条路径都可工作

4. **避免把“生成产物思维”带进模板仓库**
   - 在这里看到的 `template/*` 是“源模板”，不是最终项目文件
   - 修改时优先考虑“生成后用户体验”而非当前仓库运行效果

---

## 4) 常用命令（针对本仓库）

- 安装/进入开发环境
  - `devbox shell`

- 本地验证模板可复制（示例）
  - `copier copy --trust --skip-tasks --defaults . /tmp/test_project`

- 生成后项目常见下一步（来自模板引导）
  - `bazel run //tools:bazel_env`
  - `bazel test //...`
  - `bazel run gazelle`

---

## 5) AI 修改建议（高价值）

- 优先做“小步可验证”改动：一次只做一个主题（如只改语言开关、只改文档、只改工具链）。
- 改 `copier.yml` 时，重点审查：
  - `langs` 多选项与布尔派生字段是否一致
  - `_exclude` 条件是否覆盖新增能力
  - `_tasks` 是否会在未启用语言时误执行
- 改 `template/tools/BUILD.jinja`、`template/BUILD.jinja` 时，优先检查条件 load 与 rule 的配对关系，避免出现“未启用语言却引用规则”的渲染后错误。

---

## 6) 最小验证清单（提交前）

- 文档改动：
  - 结构完整、术语与仓库现状一致

- 模板逻辑改动：
  - 至少执行一次 `copier copy` 到临时目录
  - 检查生成结果是否包含/排除了预期文件

- 脚本改动（`*.axl`）：
  - 验证找不到依赖时的报错可读
  - 验证成功路径命令参数正确（如 `--trust`、`--defaults`、`--skip-tasks`）

---

## 7) 快速心智模型（一句话）

把这个仓库当成“会生成项目的编译器前端”：`copier.yml` 是配置与条件逻辑，`template/` 是输出模板源码，`init.axl`/`update.axl` 是执行入口。
