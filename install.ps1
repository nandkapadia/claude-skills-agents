#
# Install Claude Code and GitHub Copilot skills and agents (Windows)
# Usage: .\install.ps1 [OPTIONS]
#
# Options:
#   -ClaudeOnly    Install only to Claude Code
#   -CopilotOnly   Install only to GitHub Copilot
#   -Help          Show this help message
#
# Paths:
#   Claude:  %USERPROFILE%\.claude\skills\ and %USERPROFILE%\.claude\agents\
#   Copilot: %USERPROFILE%\.copilot\skills\ and %USERPROFILE%\.copilot\agents\
#

param(
    [switch]$ClaudeOnly,
    [switch]$CopilotOnly,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Get-Content $MyInvocation.MyCommand.Path | Select-Object -First 13 | Select-Object -Skip 1
    exit 0
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Default: install to both
$InstallClaude = -not $CopilotOnly
$InstallCopilot = -not $ClaudeOnly

function Install-Skills {
    param(
        [string]$SourceDir,
        [string]$TargetDir,
        [string]$Platform
    )

    Write-Host ""
    Write-Host "Installing skills to $TargetDir" -ForegroundColor Blue
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

    $SkillDirs = Get-ChildItem -Path $SourceDir -Directory -ErrorAction SilentlyContinue

    foreach ($SkillDir in $SkillDirs) {
        $SkillName = $SkillDir.Name
        $DestDir = Join-Path $TargetDir $SkillName

        if (Test-Path $DestDir) {
            Write-Host "  [UPDATE] $SkillName" -ForegroundColor Yellow
            Remove-Item -Recurse -Force $DestDir
        } else {
            Write-Host "  [NEW] $SkillName" -ForegroundColor Green
        }

        Copy-Item -Recurse -Path $SkillDir.FullName -Destination $DestDir
    }
}

function Install-Agents {
    param(
        [string]$SourceDir,
        [string]$TargetDir,
        [string]$Platform
    )

    Write-Host ""
    Write-Host "Installing agents to $TargetDir" -ForegroundColor Blue
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

    $AgentFiles = Get-ChildItem -Path $SourceDir -Filter "*.md" -ErrorAction SilentlyContinue

    foreach ($AgentFile in $AgentFiles) {
        $AgentName = $AgentFile.Name
        $DestFile = Join-Path $TargetDir $AgentName

        if (Test-Path $DestFile) {
            Write-Host "  [UPDATE] $AgentName" -ForegroundColor Yellow
        } else {
            Write-Host "  [NEW] $AgentName" -ForegroundColor Green
        }

        Copy-Item -Path $AgentFile.FullName -Destination $DestFile -Force
    }
}

Write-Host "Skills & Agents Installer" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

# Install to Claude Code
if ($InstallClaude) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "Claude Code" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

    $ClaudeDir = Join-Path $env:USERPROFILE ".claude"
    Install-Skills -SourceDir (Join-Path $ScriptDir "skills") -TargetDir (Join-Path $ClaudeDir "skills") -Platform "Claude"
    Install-Agents -SourceDir (Join-Path $ScriptDir "agents") -TargetDir (Join-Path $ClaudeDir "agents") -Platform "Claude"
}

# Install to GitHub Copilot
if ($InstallCopilot) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "GitHub Copilot" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

    $CopilotDir = Join-Path $env:USERPROFILE ".copilot"

    # Use copilot/ subdirectory as source if it exists
    $CopilotSkillsSource = Join-Path $ScriptDir "copilot\skills"
    $CopilotAgentsSource = Join-Path $ScriptDir "copilot\agents"

    if (Test-Path $CopilotSkillsSource) {
        Install-Skills -SourceDir $CopilotSkillsSource -TargetDir (Join-Path $CopilotDir "skills") -Platform "Copilot"
    } else {
        Install-Skills -SourceDir (Join-Path $ScriptDir "skills") -TargetDir (Join-Path $CopilotDir "skills") -Platform "Copilot"
    }

    if (Test-Path $CopilotAgentsSource) {
        Install-Agents -SourceDir $CopilotAgentsSource -TargetDir (Join-Path $CopilotDir "agents") -Platform "Copilot"
    } else {
        Install-Agents -SourceDir (Join-Path $ScriptDir "agents") -TargetDir (Join-Path $CopilotDir "agents") -Platform "Copilot"
    }
}

# Summary
Write-Host ""
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""

if ($InstallClaude) {
    Write-Host "Claude Code:"
    Write-Host "  Skills: ~/.claude/skills/"
    Write-Host "  Agents: ~/.claude/agents/"
}

if ($InstallCopilot) {
    Write-Host "GitHub Copilot:"
    Write-Host "  Skills: ~/.copilot/skills/"
    Write-Host "  Agents: ~/.copilot/agents/"
}

Write-Host ""
Write-Host "Skills installed:"
Get-ChildItem -Path (Join-Path $ScriptDir "skills") -Directory -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  - $($_.Name)" }
Write-Host ""
Write-Host "Agents installed:"
Get-ChildItem -Path (Join-Path $ScriptDir "agents") -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  - $($_.BaseName)" }
Write-Host ""
Write-Host "Restart your AI coding assistant to use the new skills and agents."
