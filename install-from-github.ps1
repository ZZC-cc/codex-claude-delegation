param(
  [string]$Repo = 'ZZC-cc/codex-claude-delegation',
  [string]$Ref = 'main',
  [string]$CodexHome = "$env:USERPROFILE\.codex",
  [switch]$Force
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Write-Step {
  param([string]$Message)
  Write-Output "[codex-claude-delegation] $Message"
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-claude-delegation-" + [guid]::NewGuid().ToString('N'))
$zipPath = Join-Path $tempRoot 'repo.zip'
$extractPath = Join-Path $tempRoot 'extract'

try {
  New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
  New-Item -ItemType Directory -Force -Path $extractPath | Out-Null

  $zipUrl = "https://codeload.github.com/$Repo/zip/refs/heads/$Ref"
  Write-Step "Downloading $Repo@$Ref"
  Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

  Write-Step "Extracting package"
  Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

  $repoDir = Get-ChildItem -LiteralPath $extractPath -Directory | Select-Object -First 1
  if (-not $repoDir) {
    throw "Downloaded archive did not contain a repository directory."
  }

  $source = Join-Path $repoDir.FullName 'skills\claude-delegation'
  if (-not (Test-Path -LiteralPath $source)) {
    throw "Skill source not found in downloaded archive: $source"
  }

  $destRoot = Join-Path $CodexHome 'skills'
  $dest = Join-Path $destRoot 'claude-delegation'

  New-Item -ItemType Directory -Force -Path $destRoot | Out-Null

  if (Test-Path -LiteralPath $dest) {
    if (-not $Force) {
      throw "Skill already exists: $dest. Re-run with -Force to overwrite."
    }
    Write-Step "Overwriting existing skill"
    Remove-Item -LiteralPath $dest -Recurse -Force
  }

  Copy-Item -LiteralPath $source -Destination $dest -Recurse

  Write-Step "Installed claude-delegation to $dest"
  Write-Step "Restart Codex to pick up the new skill."
} finally {
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}

