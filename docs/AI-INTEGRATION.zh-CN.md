# AI 接入指南

当你想让 Codex、Claude Code 或其他 AI 编程助手帮你安装这个 Skill 时，可以直接使用本页。

## 最快安装

在 PowerShell 里运行：

```powershell
irm https://raw.githubusercontent.com/ZZC-cc/codex-claude-delegation/main/install-from-github.ps1 | iex
```

如果已经安装过，需要覆盖：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ZZC-cc/codex-claude-delegation/main/install-from-github.ps1))) -Force"
```

安装后重启 Codex。

## 给 Codex 的提示词

复制下面这段给 Codex：

```text
请帮我安装 Codex Claude Delegation 这个 Codex Skill：
https://github.com/ZZC-cc/codex-claude-delegation

优先使用仓库里的快速安装脚本。安装后请验证：
1. Skill 位于 %USERPROFILE%\.codex\skills\claude-delegation。
2. SKILL.md、scripts\invoke-claude.ps1、references\delegation-contract.md 都存在。
3. 本机 Claude Code CLI 可以通过 `claude --version` 调用。

不要触碰 secrets、auth tokens、credential stores 或无关文件。安装完成后提醒我重启 Codex。
```

## 给 Claude Code 的提示词

复制下面这段给 Claude Code：

```text
请帮我安装这个 Codex Skill 包：
https://github.com/ZZC-cc/codex-claude-delegation

只需要把 `skills/claude-delegation` 安装到我的 Codex skills 目录：
%USERPROFILE%\.codex\skills\claude-delegation

优先使用项目里的 PowerShell 安装脚本。安装后验证文件是否存在。不要编辑无关的 Codex 配置、凭据或认证文件。
```

## AI 应该做什么

AI 助手应该：

1. 检查 PowerShell 是否可用。
2. 下载或 clone 这个仓库。
3. 把 `skills/claude-delegation` 复制到本地 Codex skills 目录。
4. 验证 `claude --version`。
5. 提醒用户重启 Codex。

AI 不应该：

- 修改账号凭据。
- 修改无关的 Codex 配置。
- 在用户没有明确要求时安装 bridge daemon 或 MCP server。
- 执行破坏性 git 命令。

