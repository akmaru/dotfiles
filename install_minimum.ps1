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

Write-Host "[1/4] Installing Chocolatey packages..." -ForegroundColor Yellow

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
Write-Host "[2/4] Creating directories..." -ForegroundColor Yellow

$dirs = @(
    "$HOME\.ssh\config.d"
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
Write-Host "[3/4] Setting up Git config..." -ForegroundColor Yellow

New-Symlink -Link "$HOME\.gitconfig" -Target "$DotPath\.gitconfig"

# ============================================================
# SSH
# ============================================================

Write-Host ""
Write-Host "[4/4] Setting up SSH config..." -ForegroundColor Yellow

New-Symlink -Link "$HOME\.ssh\config" -Target "$DotPath\.ssh\config"

# ============================================================
# Done
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Install complete!"
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
