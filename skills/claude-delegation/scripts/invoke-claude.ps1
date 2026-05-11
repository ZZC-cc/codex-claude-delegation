param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('plan', 'review', 'debug', 'implement', 'adversarial-review')]
  [string]$Mode,

  [Parameter(Mandatory = $true)]
  [string]$Task,

  [string]$ContextFile,
  [string]$WorkDir = (Get-Location).Path,
  [string]$AllowedWriteScope = 'none',
  [int]$TimeoutSeconds = 1800
)

$ErrorActionPreference = 'Stop'

function New-SafeName {
  param([string]$Value)
  $safe = $Value -replace '[^a-zA-Z0-9._-]+', '-'
  if ($safe.Length -gt 60) {
    return $safe.Substring(0, 60).Trim('-')
  }
  return $safe.Trim('-')
}

function Quote-WindowsArgument {
  param([AllowNull()][string]$Argument)

  if ($null -eq $Argument -or $Argument.Length -eq 0) {
    return '""'
  }

  $result = '"'
  $backslashes = 0

  foreach ($char in $Argument.ToCharArray()) {
    if ($char -eq '\') {
      $backslashes++
      continue
    }

    if ($char -eq '"') {
      if ($backslashes -gt 0) {
        $result += ('\' * ($backslashes * 2))
        $backslashes = 0
      }
      $result += '\"'
      continue
    }

    if ($backslashes -gt 0) {
      $result += ('\' * $backslashes)
      $backslashes = 0
    }

    $result += $char
  }

  if ($backslashes -gt 0) {
    $result += ('\' * ($backslashes * 2))
  }

  $result += '"'
  return $result
}

$claude = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claude) {
  throw "Claude Code CLI was not found on PATH. Install Claude Code or add claude.exe to PATH."
}

$resolvedWorkDir = Resolve-Path -LiteralPath $WorkDir

$context = ''
if ($ContextFile) {
  $resolvedContext = Resolve-Path -LiteralPath $ContextFile
  $context = [System.IO.File]::ReadAllText($resolvedContext, [System.Text.Encoding]::UTF8)
}

$writeRule = if ($Mode -eq 'implement') {
  "You may edit only this write scope: $AllowedWriteScope"
} else {
  "Do not edit files. Return analysis only."
}

$prompt = @"
You are Claude Code working as a bounded collaborator for Codex.

Mode:
$Mode

Task:
$Task

Context:
$context

Constraints:
- Work on Windows/PowerShell unless repository conventions clearly require another shell.
- Do not run destructive git commands.
- Do not touch secrets, auth tokens, credential stores, or account switching files.
- Preserve unrelated user changes.
- If Playwright CLI is needed, use --headed.
- $writeRule

Allowed write scope:
$AllowedWriteScope

Expected output:
- Findings or implementation summary.
- Evidence checked.
- Files changed, if any.
- Remaining risks or follow-up questions.
"@

$runRoot = Join-Path $resolvedWorkDir '.codex-claude-delegation\runs'
New-Item -ItemType Directory -Force -Path $runRoot | Out-Null

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$slug = New-SafeName -Value $Mode
$promptPath = Join-Path $runRoot "$stamp-$slug.prompt.txt"
$outputPath = Join-Path $runRoot "$stamp-$slug.output.txt"
$errorPath = Join-Path $runRoot "$stamp-$slug.error.txt"

[System.IO.File]::WriteAllText($promptPath, $prompt, [System.Text.UTF8Encoding]::new($false))

$psi = [System.Diagnostics.ProcessStartInfo]::new()
$psi.FileName = $claude.Source
$psi.WorkingDirectory = $resolvedWorkDir
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
$psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8
$args = @('-p', '--output-format', 'text', $prompt)
$psi.Arguments = (($args | ForEach-Object { Quote-WindowsArgument $_ }) -join ' ')

$process = [System.Diagnostics.Process]::new()
$process.StartInfo = $psi
[void]$process.Start()

$stdoutTask = $process.StandardOutput.ReadToEndAsync()
$stderrTask = $process.StandardError.ReadToEndAsync()

if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
  try { $process.Kill($true) } catch { $process.Kill() }
  throw "Claude timed out after $TimeoutSeconds seconds. Prompt saved to $promptPath"
}

$stdout = $stdoutTask.GetAwaiter().GetResult()
$stderr = $stderrTask.GetAwaiter().GetResult()

[System.IO.File]::WriteAllText($outputPath, $stdout, [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText($errorPath, $stderr, [System.Text.UTF8Encoding]::new($false))

[pscustomobject]@{
  exitCode = $process.ExitCode
  promptPath = $promptPath
  outputPath = $outputPath
  errorPath = $errorPath
} | ConvertTo-Json -Depth 3

if ($process.ExitCode -ne 0) {
  throw "Claude exited with code $($process.ExitCode). See $errorPath"
}
