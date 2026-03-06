#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path $ScriptDir).Path

function Show-Usage {
    @"
Usage:
  .\build-helper.ps1 <command> [args]

Commands:
  init                Create/update .venv and install all dependencies
  start               Start JupyterLab (opens in user-work)
  launcher            Install Windows shortcuts (Desktop + Start Menu)
  help                Show this help text

Examples:
  .\build-helper.ps1 init
  .\build-helper.ps1 start
  .\build-helper.ps1 launcher
"@
}

function Fail-WithHelp([string]$Message) {
    Write-Error "[math-notebook] ERROR: $Message"
    Write-Host ""
    Show-Usage
    exit 1
}

function Invoke-SubScript([string]$ScriptName, [string[]]$ExtraArgs) {
    $ScriptPath = Join-Path $RepoRoot "scripts\powershell\$ScriptName"
    if (-not (Test-Path $ScriptPath)) {
        Fail-WithHelp "Missing script: $ScriptPath"
    }

    try {
        & $ScriptPath @ExtraArgs
    } catch {
        Fail-WithHelp "Command failed: $ScriptName"
    }
}

function Main {
    param([string[]]$Args)

    $cmd = "help"
    $rest = @()

    if ($Args.Count -gt 0) {
        $cmd = $Args[0]
        if ($Args.Count -gt 1) {
            $rest = $Args[1..($Args.Count - 1)]
        }
    }

    switch ($cmd) {
        "init" {
            Invoke-SubScript -ScriptName "install.ps1" -ExtraArgs $rest
        }
        "install" {  # alias for compatibility
            Invoke-SubScript -ScriptName "install.ps1" -ExtraArgs $rest
        }
        "start" {
            Invoke-SubScript -ScriptName "start.ps1" -ExtraArgs $rest
        }
        "launcher" {
            Invoke-SubScript -ScriptName "install-launcher.ps1" -ExtraArgs $rest
        }
        "install-launcher" {  # alias for compatibility
            Invoke-SubScript -ScriptName "install-launcher.ps1" -ExtraArgs $rest
        }
        "help" {
            Show-Usage
        }
        "-h" {
            Show-Usage
        }
        "--help" {
            Show-Usage
        }
        default {
            Fail-WithHelp "Unknown command: $cmd"
        }
    }
}

Main -Args $args
