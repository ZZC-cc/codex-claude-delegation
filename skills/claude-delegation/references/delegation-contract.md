# Delegation Contract

Use this shape when handing work from Codex to Claude Code.

```text
You are Claude Code working as a bounded collaborator for Codex.

Mode:
<plan | review | debug | implement | adversarial-review>

Task:
<one concrete task>

Context:
<short, relevant repo or problem context>

Constraints:
- Work on Windows/PowerShell unless local repo conventions say otherwise.
- Do not run destructive git commands.
- Do not touch secrets or auth token files.
- Preserve unrelated user changes.
- If Playwright CLI is needed, use --headed.

Allowed write scope:
<none for review/plan/debug, or exact files/directories for implement>

Success criteria:
<what a good answer must prove or contain>

Expected output:
- Findings or implementation summary.
- Evidence checked.
- Files changed, if any.
- Remaining risks or follow-up questions.
```

For code review, use findings-first output:

```text
Findings:
- [severity] file:line issue and impact

Open questions:
- ...

Verification gaps:
- ...
```

For implementation, require:

```text
Changed files:
- ...

Verification:
- command/result

Notes:
- ...
```

