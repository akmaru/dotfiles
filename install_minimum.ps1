#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DotPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Dotfiles Minimum Install (Windows)"
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# Helper: Create symlink (remove existing first)
# ============================================================

function New-Symlink {
    param(
        [string]$Link,
        [string]$Target
    )

    if (Test-Path $Link) {
        Remove-Item $Link -Force -Recurse
    }

    $parentDir = Split-Path -Parent $Link
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (Test-Path $Target -PathType Container) {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
    } else {
        New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
    }

    Write-Host "  $Link -> $Target" -ForegroundColor Green
}

# ============================================================
# Chocolatey packages
# ============================================================

Write-Host "[1/6] Installing Chocolatey packages..." -ForegroundColor Yellow

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "  Chocolatey not found. Installing..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

$packages = @("git", "jq", "nodejs")
foreach ($pkg in $packages) {
    if (-not (choco list --local-only --exact $pkg 2>$null | Select-String "^$pkg ")) {
        choco install -y $pkg
    } else {
        Write-Host "  $pkg is already installed" -ForegroundColor DarkGray
    }
}

# Refresh PATH after package installation
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# ============================================================
# Directories
# ============================================================

Write-Host ""
Write-Host "[2/6] Creating directories..." -ForegroundColor Yellow

$dirs = @(
    "$HOME\.config\mcp\master-mcp.d",
    "$HOME\.ssh\config.d",
    "$HOME\.claude"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Created $dir" -ForegroundColor Green
    }
}

# ============================================================
# Git
# ============================================================

Write-Host ""
Write-Host "[3/6] Setting up Git config..." -ForegroundColor Yellow

New-Symlink -Link "$HOME\.gitconfig" -Target "$DotPath\.gitconfig"
New-Symlink -Link "$HOME\.gitconfig_os" -Target "$DotPath\.gitconfig_windows"

# ============================================================
# SSH
# ============================================================

Write-Host ""
Write-Host "[4/6] Setting up SSH config..." -ForegroundColor Yellow

New-Symlink -Link "$HOME\.ssh\config" -Target "$DotPath\.ssh\config"

# ============================================================
# MCP
# ============================================================

Write-Host ""
Write-Host "[5/6] Setting up MCP config..." -ForegroundColor Yellow

New-Symlink -Link "$HOME\.config\mcp\master-mcp.json" -Target "$DotPath\mcp\master-mcp.json"

# Run sync-mcp.sh via Git Bash
$gitBash = "C:\Program Files\Git\bin\bash.exe"
if (Test-Path $gitBash) {
    Write-Host "  Running sync-mcp.sh via Git Bash..." -ForegroundColor Cyan
    # Set XDG variables for sync-mcp.sh
    $env:XDG_BIN_HOME = "$HOME\.local\bin"
    $env:XDG_CONFIG_HOME = "$HOME\.config"
    & $gitBash -c "export HOME='$($HOME -replace '\\','/')'; export XDG_BIN_HOME=`"`$HOME/.local/bin`"; export XDG_CONFIG_HOME=`"`$HOME/.config`"; cd '$($DotPath -replace '\\','/')' && bash mcp/sync-mcp.sh claude"
} else {
    Write-Host "  [WARN] Git Bash not found. Skipping sync-mcp.sh." -ForegroundColor Yellow
    Write-Host "         Run manually after installing Git for Windows:" -ForegroundColor Yellow
    Write-Host "         bash mcp/sync-mcp.sh" -ForegroundColor Yellow
}

# ============================================================
# Claude Code
# ============================================================

Write-Host ""
Write-Host "[6/6] Setting up Claude Code..." -ForegroundColor Yellow

# Install Claude Code CLI
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "  Installing Claude Code..." -ForegroundColor Cyan
    npm install -g @anthropic-ai/claude-code
} else {
    Write-Host "  Claude Code is already installed" -ForegroundColor DarkGray
}

# Symlink configuration files
if (Test-Path "$DotPath\claude-user\settings.json") {
    New-Symlink -Link "$HOME\.claude\settings.json" -Target "$DotPath\claude-user\settings.json"
}

if (Test-Path "$DotPath\claude-user\CLAUDE.md") {
    New-Symlink -Link "$HOME\.claude\CLAUDE.md" -Target "$DotPath\claude-user\CLAUDE.md"
}

if (Test-Path "$DotPath\claude-user\agents") {
    New-Symlink -Link "$HOME\.claude\agents" -Target "$DotPath\claude-user\agents"
}

if (Test-Path "$DotPath\claude-user\rules") {
    New-Symlink -Link "$HOME\.claude\rules" -Target "$DotPath\claude-user\rules"
}

# ============================================================
# Done
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Install complete!"
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
