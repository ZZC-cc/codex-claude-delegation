# AI Integration Guide

Use this page when you want an AI coding assistant to install or wire this skill for you.

## Fastest Install

Run this in PowerShell:

```powershell
irm https://raw.githubusercontent.com/ZZC-cc/codex-claude-delegation/main/install-from-github.ps1 | iex
```

If the skill already exists and you want to overwrite it:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create((irm https://raw.githubusercontent.com/ZZC-cc/codex-claude-delegation/main/install-from-github.ps1))) -Force"
```

Restart Codex after installation.

## Prompt For Codex

Copy this into Codex:

```text
Install the Codex Claude Delegation skill from:
https://github.com/ZZC-cc/codex-claude-delegation

Use the repository's quick installer if possible. Verify that:
1. The skill exists at %USERPROFILE%\.codex\skills\claude-delegation.
2. SKILL.md, scripts\invoke-claude.ps1, and references\delegation-contract.md exist.
3. The local Claude Code CLI is available with `claude --version`.

Do not touch secrets, auth tokens, credential stores, or unrelated files. After installation, tell me to restart Codex.
```

## Prompt For Claude Code

Copy this into Claude Code:

```text
Help me install this Codex skill package:
https://github.com/ZZC-cc/codex-claude-delegation

Please install only the `skills/claude-delegation` folder into my Codex skills directory:
%USERPROFILE%\.codex\skills\claude-delegation

Use the project's PowerShell installer if possible. Verify the installed files and do not edit unrelated Codex configuration, credentials, or auth files.
```

## What The AI Should Do

The assistant should:

1. Check that PowerShell is available.
2. Download or clone this repository.
3. Copy `skills/claude-delegation` into the local Codex skills directory.
4. Verify `claude --version`.
5. Ask the user to restart Codex.

The assistant should not:

- Modify account credentials.
- Change unrelated Codex config.
- Install bridge daemons or MCP servers unless the user explicitly asks.
- Run destructive git commands.

