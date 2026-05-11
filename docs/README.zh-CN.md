# Codex Claude Delegation

[English](../README.md) | 中文 | [AI 接入指南](AI-INTEGRATION.zh-CN.md)

这是一个轻量、本地优先的 Codex Skill 项目，用来让 OpenAI Codex 把边界清晰的任务委派给本机 Claude Code CLI。

它不是大型多智能体平台。设计原则是：Codex 仍然是主控，Claude Code 只是被临时调用的 reviewer、planner、debugger 或 bounded worker。每一次交接都必须有明确的任务、上下文、约束、写入范围和期望输出。

## 为什么做这个项目

现有的跨 Agent 项目通常很强，但也比较重：可能需要 daemon、MCP server、tmux、Web UI、长期 session hub 等。这个项目先做最小可用版本：

- 一个 Codex 可识别的 `SKILL.md`；
- 一个稳定的 PowerShell 调用脚本；
- 一个标准化任务交接契约；
- 本地运行记录，方便复盘。

第一版重点适配 Windows + PowerShell，也尽量保持以后迁移到其他平台的可能性。

## 参考项目

这个项目参考了这些优秀项目的思想：

- `openai/codex-plugin-cc`：官方的 coding agent review / rescue 交互模式；
- `SeemSeam/claude_codex_bridge`：跨 agent 指派和持续协作思路；
- `BeehiveInnovations/pal-mcp-server`：CLI 到 CLI 的 worker 委派模型；
- `803/skills-supply`、`athola/skrills`：跨多个 Agent CLI 复用 skills 的组织方式。

但第一版不依赖这些项目，避免一开始就引入过多复杂度。

## 功能

- 从 Codex 调用本机 `claude -p`。
- 支持五种模式：`plan`、`review`、`debug`、`implement`、`adversarial-review`。
- 自动把 prompt、stdout、stderr 写入 `.codex-claude-delegation/runs/`。
- 兼容 Windows PowerShell 5，并尽量保持 UTF-8 输出。
- 通过明确的 constraints 和 allowed write scope 限制 Claude 的任务边界。
- 安装到 `%USERPROFILE%\.codex\skills\claude-delegation`。

## 前置条件

- Windows PowerShell。
- 支持本地 skills 的 OpenAI Codex。
- Claude Code CLI 已安装，并且 `claude` 在 `PATH` 中可用。

检查 Claude：

```powershell
claude --version
```

## 安装

### 快速安装

复制下面这段给 Codex、Claude Code 或其他 AI 编程助手，让它直接帮你安装：

```text
请帮我安装这个 Codex Skill 包：
https://github.com/ZZC-cc/codex-claude-delegation

请使用快速安装脚本：
irm https://raw.githubusercontent.com/ZZC-cc/codex-claude-delegation/main/install-from-github.ps1 | iex

安装后请验证：
1. Skill 位于 %USERPROFILE%\.codex\skills\claude-delegation。
2. SKILL.md、scripts\invoke-claude.ps1、references\delegation-contract.md 都存在。
3. 本机 Claude Code 可以通过 `claude --version` 调用。

不要触碰 secrets、auth tokens、credential stores 或无关的 Codex 配置。完成后提醒我重启 Codex。
```

或者自己在 PowerShell 里运行：

```powershell
irm https://raw.githubusercontent.com/ZZC-cc/codex-claude-delegation/main/install-from-github.ps1 | iex
```

如果已经安装过，需要覆盖：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ZZC-cc/codex-claude-delegation/main/install-from-github.ps1))) -Force"
```

安装后需要重启 Codex，新的 Skill 才会被加载。

### 从本地 clone 安装

克隆仓库后运行：

```powershell
.\install.ps1
```

如果已经安装过，要覆盖当前版本：

```powershell
.\install.ps1 -Force
```

### 更多 AI 提示词

如果你想看更完整的 Codex / Claude Code 接入提示词，可以参考 [AI 接入指南](AI-INTEGRATION.zh-CN.md)。


## 使用方式

重启 Codex 后，可以自然语言触发：

```text
让 Claude Code 帮我 review 这个改动，先不要改文件。
```

```text
让 Claude 对这个权限设计做一次 adversarial review。
```

```text
把这个 bug 排查任务委派给 Claude，但只让它输出根因和证据。
```

Codex 会触发 `claude-delegation` skill，构造结构化交接 prompt，调用脚本，读取 Claude 输出，然后由 Codex 决定下一步怎么处理。

## 手动调用

也可以直接运行脚本：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\skills\claude-delegation\scripts\invoke-claude.ps1 `
  -Mode review `
  -Task "Review the recent auth changes for security regressions." `
  -WorkDir "D:\path\to\repo"
```

如果允许 Claude 做实现，必须指定写入范围：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\skills\claude-delegation\scripts\invoke-claude.ps1 `
  -Mode implement `
  -Task "Add missing unit tests for the parser." `
  -AllowedWriteScope "tests/parser/*.test.ts" `
  -WorkDir "D:\path\to\repo"
```

## 委派模式

| 模式 | 适用场景 | Claude 应该做什么 |
|---|---|---|
| `plan` | 架构、实现路径或取舍还不清楚 | 输出方案、取舍、风险和推荐路径 |
| `review` | Codex 已经改完，需要第二视角审查 | 找 bug、回归、安全问题、缺失测试 |
| `debug` | 某个故障需要独立排查 | 输出可能根因和可验证证据 |
| `implement` | 用户明确希望 Claude 做一个边界清晰的实现任务 | 只修改指定文件或目录，并报告改动路径 |
| `adversarial-review` | 最终提交前需要一个反方审查 | 挑战假设、边界条件、回滚、数据丢失、权限和安全 |

## 安全模型

除非用户明确要求 Claude 修改文件，否则 Claude 的输出默认只是建议，不能盲目套用。

默认安全约束：

- 不运行破坏性 Git 命令。
- 不触碰 secrets、auth tokens、credential stores 或账号切换文件。
- 不覆盖用户无关改动。
- 默认使用 Windows / PowerShell，除非仓库约定要求其他 shell。
- 如果需要 Playwright CLI，必须使用 `--headed`。
- 非 `implement` 模式不得修改文件。

## 项目结构

```text
codex-claude-delegation/
├── install.ps1
├── LICENSE
├── README.md
├── docs/
│   └── README.zh-CN.md
└── skills/
    └── claude-delegation/
        ├── SKILL.md
        ├── references/
        │   └── delegation-contract.md
        └── scripts/
            └── invoke-claude.ps1
```

## 后续路线

- 增加可选 JSON 输出解析。
- 增加中英文 examples。
- 增加 `claude-review` 便利 wrapper。
- 可选接入 CCB、PAL MCP 等 bridge 项目。
- 增加健康检查脚本，验证 Claude CLI 和 Skill 安装状态。
