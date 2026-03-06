#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Path logic: Assumes this script is in the RepoRoot
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
    # Sub-scripts must be in scripts\powershell\ relative to the root
    $ScriptPath = Join-Path $RepoRoot "scripts\powershell\$ScriptName"
    
    if (-not (Test-Path $ScriptPath)) {
        Fail-WithHelp "Missing script: $ScriptPath. Ensure you have created the 'scripts\powershell\' folder structure."
    }

    try {
        & $ScriptPath @ExtraArgs
    } catch {
        # Improved error reporting to debug permission/access issues
        Write-Host "`n--- System Error Details ---" -ForegroundColor Red
        Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Check your PowerShell ExecutionPolicy or folder permissions.`n" -ForegroundColor Gray
        
        Fail-WithHelp "Command failed: $ScriptName"
    }
}

function Main {
    # Renamed parameter to avoid shadowing the automatic $Args variable
    param([string[]]$CommandArgs) 

    $cmd = "help"
    $rest = @()

    if ($CommandArgs.Count -gt 0) {
        $cmd = $CommandArgs[0]
        # Fixed range bug: Select-Object correctly handles single-argument calls
        $rest = $CommandArgs | Select-Object -Skip 1
    }

    switch ($cmd) {
        "init" {
            Invoke-SubScript -ScriptName "install.ps1" -ExtraArgs $rest
        }
        "install" { 
            Invoke-SubScript -ScriptName "install.ps1" -ExtraArgs $rest
        }
        "start" {
            Invoke-SubScript -ScriptName "start.ps1" -ExtraArgs $rest
        }
        "launcher" {
            Invoke-SubScript -ScriptName "install-launcher.ps1" -ExtraArgs $rest
        }
        "help" {
            Show-Usage
        }
        default {
            Fail-WithHelp "Unknown command: $cmd"
        }
    }
}

# Pass the script's arguments into the Main function
Main -CommandArgs $args