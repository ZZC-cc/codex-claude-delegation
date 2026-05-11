# Codex Claude Delegation

English | [中文](docs/README.zh-CN.md) | [AI Integration Guide](docs/AI-INTEGRATION.md)

A small, local-first Codex skill package that lets OpenAI Codex delegate bounded work to the local Claude Code CLI.

The goal is not to build a heavy multi-agent platform. Codex stays in control, Claude Code acts as a scoped worker or reviewer, and every handoff uses an explicit contract.

## Why

Many cross-agent projects are powerful but heavy: daemons, MCP servers, tmux sessions, web UIs, or persistent hubs. This project starts with the smallest useful layer:

- a Codex `SKILL.md`;
- a reusable PowerShell invocation script;
- a structured delegation contract;
- local run logs for review.

It is designed for Windows-first workflows, while still being easy to port later.

## Inspiration

This project borrows ideas from:

- `openai/codex-plugin-cc`: official UX pattern for review/rescue between coding agents;
- `SeemSeam/claude_codex_bridge`: cross-agent delegation commands and persistent collaboration;
- `BeehiveInnovations/pal-mcp-server`: CLI-to-CLI worker delegation;
- `803/skills-supply` and `athola/skrills`: reusable skills across multiple agent CLIs.

The v1 implementation intentionally avoids requiring those projects.

## Features

- Delegate from Codex to Claude Code with `claude -p`.
- Supports five modes: `plan`, `review`, `debug`, `implement`, `adversarial-review`.
- Writes prompt, stdout, and stderr to `.codex-claude-delegation/runs/`.
- Works with Windows PowerShell 5 and UTF-8 output.
- Keeps Claude scoped with explicit constraints and allowed write scope.
- Installs into `%USERPROFILE%\.codex\skills\claude-delegation`.

## Requirements

- Windows PowerShell.
- OpenAI Codex with local skills support.
- Claude Code CLI available as `claude` on `PATH`.

Check Claude:

```powershell
claude --version
```

## Install

### Quick Install

Run this in PowerShell:

```powershell
irm https://raw.githubusercontent.com/ZZC-cc/codex-claude-delegation/main/install-from-github.ps1 | iex
```

If the skill already exists and you want to overwrite it:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ZZC-cc/codex-claude-delegation/main/install-from-github.ps1))) -Force"
```

Restart Codex after installing so it can load the new skill.

### Install From A Local Clone

Clone the repository, then run:

```powershell
.\install.ps1
```

Overwrite an existing install:

```powershell
.\install.ps1 -Force
```

### Ask AI To Install It

If you want Codex or Claude Code to install this package for you, copy the prompts in [AI Integration Guide](docs/AI-INTEGRATION.md).

## Usage

After restarting Codex, ask naturally:

```text
Ask Claude Code to review this change before we finalize it.
```

```text
Use Claude as an adversarial reviewer for this permission design.
```

```text
Delegate a debugging pass to Claude, but do not let it edit files.
```

Codex should trigger the `claude-delegation` skill, build a bounded prompt, call the bundled script, read Claude's output, and decide what to do next.

## Manual Invocation

You can call the script directly:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\skills\claude-delegation\scripts\invoke-claude.ps1 `
  -Mode review `
  -Task "Review the recent auth changes for security regressions." `
  -WorkDir "D:\path\to\repo"
```

For implementation tasks, pass an explicit write scope:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\skills\claude-delegation\scripts\invoke-claude.ps1 `
  -Mode implement `
  -Task "Add missing unit tests for the parser." `
  -AllowedWriteScope "tests/parser/*.test.ts" `
  -WorkDir "D:\path\to\repo"
```

## Delegation Modes

| Mode | Use When | Claude Should |
|---|---|---|
| `plan` | Architecture or implementation strategy is unclear | Produce options, tradeoffs, risks, and a recommended path |
| `review` | Code has changed and needs a second opinion | Find bugs, regressions, security issues, and missing tests |
| `debug` | A failure needs independent investigation | Identify likely root cause and evidence to verify |
| `implement` | The user explicitly wants Claude to do bounded code work | Edit only the assigned files and report changed paths |
| `adversarial-review` | Codex wants a skeptical pass before finalizing | Challenge assumptions, edge cases, rollback, data loss, auth, and security |

## Safety Model

Claude's result is advisory unless the user explicitly asks Claude to edit files.

Default constraints:

- Do not run destructive git commands.
- Do not touch secrets, auth tokens, credential stores, or account switching files.
- Preserve unrelated user changes.
- Use Windows/PowerShell unless repo conventions require otherwise.
- If Playwright CLI is needed, use `--headed`.
- For non-implementation modes, do not edit files.

## Project Layout

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

## Roadmap

- Add optional JSON output parsing.
- Add an English/Chinese example gallery.
- Add a direct `claude-review` convenience wrapper.
- Add optional integration with bridge projects such as CCB or PAL MCP.
- Add a test script that verifies local Claude availability and skill install health.
