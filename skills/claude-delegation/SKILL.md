---
name: claude-delegation
description: Delegate bounded coding, review, debugging, planning, or adversarial analysis tasks from Codex to the local Claude Code CLI. Use when the user asks Codex to ask Claude, assign work to Claude Code, cross-review with Claude, get a second-opinion review, compare Codex and Claude reasoning, or run Claude as a worker/reviewer for implementation planning, code review, bug investigation, or risk analysis.
---

# Claude Delegation

Use this skill when Codex should involve Claude Code as a bounded collaborator while Codex remains the orchestrator.

## Core rule

Do not hand Claude vague ownership of the whole project. Delegate a narrow task with:

- task
- context
- constraints
- allowed write scope
- expected output
- success criteria

Claude's result is advisory unless the user explicitly asked for Claude to edit files. Codex must review the result before acting on it.

## Modes

Choose the narrowest mode:

| Mode | Use when | Claude should |
|---|---|---|
| `plan` | architecture or implementation strategy is unclear | produce options, tradeoffs, risks, and recommended path |
| `review` | code has changed and needs second-opinion review | find bugs, regressions, security issues, missing tests |
| `debug` | a failure needs independent investigation | identify likely root cause and concrete evidence to verify |
| `implement` | user explicitly wants Claude to do bounded code work | edit only the assigned files and report changed paths |
| `adversarial-review` | Codex wants a skeptical pass before finalizing | challenge assumptions, edge cases, rollback, data loss, auth, security |

## Invocation

Use the bundled script:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <skill-dir>\scripts\invoke-claude.ps1 -Mode review -Task "<task>" -WorkDir "<repo>"
```

Prefer passing a concise `-Task` string. If context is long, write it to a temp UTF-8 file and pass `-ContextFile`.

The script writes each run under:

```text
<WorkDir>\.codex-claude-delegation\runs\
```

Read the returned output path before deciding the next step.

## Prompt contract

For non-trivial tasks, read `references/delegation-contract.md` and use its handoff shape.

## Safety

- For review, planning, and debug modes, tell Claude not to edit files.
- For implementation mode, specify exact allowed files or directories.
- Never ask Claude to handle secrets, auth tokens, private keys, or account switching credentials.
- Do not let Claude run destructive git commands.
- On Windows, prefer PowerShell commands and preserve UTF-8 output.
- If browser verification is required, include the user's rule that Playwright CLI should use `--headed`.

## Result handling

After Claude returns:

1. Summarize the useful findings.
2. Ignore speculative or unsupported claims.
3. Verify code or runtime claims locally before changing files.
4. If Claude edited files, inspect the diff before continuing.
5. Keep the final answer focused on what changed, what was verified, and any remaining risk.

