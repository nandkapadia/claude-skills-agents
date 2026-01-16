#
# Install Claude Code skills and agents to global directory (Windows)
# Usage: .\install.ps1
#
# Paths:
#   Skills: %USERPROFILE%\.claude\skills\<skill-name>\SKILL.md
#   Agents: %USERPROFILE%\.claude\agents\<agent-name>.md
#

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$SkillsDir = Join-Path $ClaudeDir "skills"
$AgentsDir = Join-Path $ClaudeDir "agents"

Write-Host "Claude Code Skills & Agents Installer" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Create directories if they don't exist
Write-Host "Creating directories..."
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null

# Install skills
Write-Host ""
Write-Host "Installing skills to $SkillsDir..."
$SkillsSource = Join-Path $ScriptDir "skills"
$SkillDirs = Get-ChildItem -Path $SkillsSource -Directory

foreach ($SkillDir in $SkillDirs) {
    $SkillName = $SkillDir.Name
    $TargetDir = Join-Path $SkillsDir $SkillName

    if (Test-Path $TargetDir) {
        Write-Host "  [UPDATE] $SkillName" -ForegroundColor Yellow
        Remove-Item -Recurse -Force $TargetDir
    } else {
        Write-Host "  [NEW] $SkillName" -ForegroundColor Green
    }

    Copy-Item -Recurse -Path $SkillDir.FullName -Destination $TargetDir
}

# Install agents
Write-Host ""
Write-Host "Installing agents to $AgentsDir..."
$AgentsSource = Join-Path $ScriptDir "agents"
$AgentFiles = Get-ChildItem -Path $AgentsSource -Filter "*.md"

foreach ($AgentFile in $AgentFiles) {
    $AgentName = $AgentFile.Name
    $TargetFile = Join-Path $AgentsDir $AgentName

    if (Test-Path $TargetFile) {
        Write-Host "  [UPDATE] $AgentName" -ForegroundColor Yellow
    } else {
        Write-Host "  [NEW] $AgentName" -ForegroundColor Green
    }

    Copy-Item -Path $AgentFile.FullName -Destination $TargetFile -Force
}

# Summary
Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Installed locations:"
Write-Host "  Skills: $SkillsDir"
Write-Host "  Agents: $AgentsDir"
Write-Host ""
Write-Host "Skills installed:"
Get-ChildItem -Path $SkillsDir -Directory | ForEach-Object { Write-Host "  - $($_.Name)" }
Write-Host ""
Write-Host "Agents installed:"
Get-ChildItem -Path $AgentsDir -Filter "*.md" | ForEach-Object { Write-Host "  - $($_.Name)" }
Write-Host ""
Write-Host "Restart Claude Code to use the new skills and agents."
