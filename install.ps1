param(
  [string]$CodexHome = "$env:USERPROFILE\.codex",
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $projectRoot 'skills\claude-delegation'
$destRoot = Join-Path $CodexHome 'skills'
$dest = Join-Path $destRoot 'claude-delegation'

if (-not (Test-Path -LiteralPath $source)) {
  throw "Skill source not found: $source"
}

New-Item -ItemType Directory -Force -Path $destRoot | Out-Null

if (Test-Path -LiteralPath $dest) {
  if (-not $Force) {
    throw "Skill already exists: $dest. Re-run with -Force to overwrite."
  }
  Remove-Item -LiteralPath $dest -Recurse -Force
}

Copy-Item -LiteralPath $source -Destination $dest -Recurse

Write-Output "Installed claude-delegation to $dest"
Write-Output "Restart Codex to pick up new skills."

