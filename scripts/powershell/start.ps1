#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve absolute paths so the script works from any current directory.
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path

# Project paths.
$VenvDir = Join-Path $RepoRoot ".venv"
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$UserWorkDir = Join-Path $RepoRoot "user-work"
$ProjectPythonDir = Join-Path $RepoRoot "python"

function Log([string]$Message) {
    Write-Host "[math-notebook] $Message"
}

function Fail([string]$Message) {
    throw "[math-notebook] ERROR: $Message"
}

# Verify the virtual environment exists and is usable.
function Require-Venv {
    if (-not (Test-Path $VenvPython)) {
        Fail "Missing virtual environment. Run .\build-helper.ps1 init first."
    }
}

# Ensure the student workspace exists before Jupyter starts.
function Ensure-UserWorkDir {
    New-Item -ItemType Directory -Path $UserWorkDir -Force | Out-Null
}

# Launch JupyterLab with project root visible, and user-work as default landing page.
function Start-Jupyter {
    # Make local helper modules importable in notebooks.
    if ([string]::IsNullOrWhiteSpace($env:PYTHONPATH)) {
        $env:PYTHONPATH = $ProjectPythonDir
    } else {
        $env:PYTHONPATH = "$ProjectPythonDir;$env:PYTHONPATH"
    }

    Log "Starting JupyterLab"
    & $VenvPython -m jupyter lab `
        --ServerApp.root_dir="$RepoRoot" `
        --ServerApp.default_url="/lab/tree/user-work" `
        --ServerApp.open_browser=true `
        @args
}

function Main {
    Require-Venv
    Ensure-UserWorkDir
    Start-Jupyter @args
}

Main @args
