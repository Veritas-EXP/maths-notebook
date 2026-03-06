#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve absolute paths so the script works from any current directory.
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path

# Project paths and constants.
$VenvDir = Join-Path $RepoRoot ".venv"
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$ReqFile = Join-Path $RepoRoot "dependencies\requirements.txt"
$UserWorkDir = Join-Path $RepoRoot "user-work"
$KernelName = "math-notebook"
$KernelDisplayName = "Python (math-notebook)"
$script:PythonBootstrapCmd = @()

function Log([string]$Message) {
    Write-Host "[math-notebook] $Message"
}

function Fail([string]$Message) {
    throw "[math-notebook] ERROR: $Message"
}

function Show-PythonInstallHelp {
    Write-Host ""
    Write-Host "Python 3.12.x is required but was not found."
    Write-Host ""
    Write-Host "Install steps (Windows):"
    Write-Host "1. Download Python 3.12.x from https://www.python.org/downloads/windows/"
    Write-Host "2. In the installer, enable:"
    Write-Host "   - Add Python to PATH"
    Write-Host "   - Install launcher (py.exe)"
    Write-Host "3. Restart PowerShell"
    Write-Host "4. Run: .\build-helper.ps1 init"
    Write-Host ""
}

function Test-PythonVersion([string[]]$CommandPrefix) {
    $exe = $CommandPrefix[0]
    $prefixArgs = @()
    if ($CommandPrefix.Length -gt 1) {
        $prefixArgs = $CommandPrefix[1..($CommandPrefix.Length - 1)]
    }

    $version = & $exe @prefixArgs -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')" 2>$null
    if ($LASTEXITCODE -ne 0) {
        return $null
    }

    return "$version".Trim()
}

function Set-PythonBootstrapCommand {
    # Prefer py launcher on Windows because it allows explicit minor version selection.
    $pyCmd = Get-Command py -ErrorAction SilentlyContinue
    if ($pyCmd) {
        $version = Test-PythonVersion @("py", "-3.12")
        if ($version) {
            $script:PythonBootstrapCmd = @("py", "-3.12")
            Log "Using Python $version via py launcher"
            return
        }
    }

    # Fallback if py is missing but python.exe is available.
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCmd) {
        $version = Test-PythonVersion @("python")
        if ($version -and $version.StartsWith("3.12.")) {
            $script:PythonBootstrapCmd = @("python")
            Log "Using Python $version via python command"
            return
        }
    }

    Show-PythonInstallHelp
    Fail "Python 3.12.x was not found."
}

function Invoke-BootstrapPython([string[]]$Args) {
    if ($script:PythonBootstrapCmd.Count -eq 0) {
        Fail "Internal error: Python command is not set."
    }

    $exe = $script:PythonBootstrapCmd[0]
    $prefixArgs = @()
    if ($script:PythonBootstrapCmd.Count -gt 1) {
        $prefixArgs = $script:PythonBootstrapCmd[1..($script:PythonBootstrapCmd.Count - 1)]
    }

    & $exe @prefixArgs @Args
}

# Create the virtual environment if it does not exist yet.
function Create-Venv {
    if (Test-Path $VenvPython) {
        Log "Using existing virtual environment: $VenvDir"
        return
    }

    if (Test-Path $VenvDir) {
        Fail "Found $VenvDir, but it is not a valid venv. Remove it and run again."
    }

    Log "Creating virtual environment at $VenvDir"
    Invoke-BootstrapPython @("-m", "venv", $VenvDir)
}

# Install and upgrade project dependencies in the venv.
function Install-Dependencies {
    if (-not (Test-Path $ReqFile)) {
        Fail "Missing requirements file: $ReqFile"
    }

    Log "Upgrading pip, setuptools, wheel"
    & $VenvPython -m pip install --upgrade pip setuptools wheel

    Log "Installing dependencies from $ReqFile"
    & $VenvPython -m pip install -r $ReqFile
}

# Ensure the student workspace directory exists.
function Ensure-UserWorkDir {
    New-Item -ItemType Directory -Path $UserWorkDir -Force | Out-Null
    Log "Ensured student workspace: $UserWorkDir"
}

# Register a named Jupyter kernel so notebooks can use this exact environment.
function Register-IPyKernel {
    Log "Registering Jupyter kernel: $KernelDisplayName"
    & $VenvPython -m ipykernel install --user --name $KernelName --display-name $KernelDisplayName
}

function Main {
    Log "Starting install"
    Set-PythonBootstrapCommand
    Create-Venv
    Install-Dependencies
    Ensure-UserWorkDir
    Register-IPyKernel
    Log "Install complete"
    Log "Next: .\build-helper.ps1 start"
}

Main
