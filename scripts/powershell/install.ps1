#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve absolute paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path

# Project paths
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

function Test-PythonVersion([string[]]$CommandPrefix) {
    $exe = $CommandPrefix[0]

    try {
        # Build the full argument list explicitly instead of splatting empty array
        if ($CommandPrefix.Count -gt 1) {
            $prefixArgs = $CommandPrefix[1..($CommandPrefix.Count - 1)]
            $version = & $exe @prefixArgs -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')" 2>$null
        } else {
            $version = & $exe -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')" 2>$null
        }
    } catch {
        return $null
    }

    if ($LASTEXITCODE -ne 0) { return $null }
    
    $trimmed = "$version".Trim()
    # Sanity check: result must look like a version number, not a banner
    if ($trimmed -notmatch '^\d+\.\d+\.\d+$') { return $null }
    return $trimmed
}

function Set-PythonBootstrapCommand {
    $pyCmd = Get-Command py -ErrorAction SilentlyContinue
    if ($pyCmd) {
        $version = Test-PythonVersion @("py", "-3.12")
        if ($version) {
            $script:PythonBootstrapCmd = @("py", "-3.12")
            Log "Using Python $version via py launcher"
            return
        }
    }

    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCmd) {
        $version = Test-PythonVersion @("python")
        if ($version -and $version.StartsWith("3.12.")) {
            $script:PythonBootstrapCmd = @("python")
            Log "Using Python $version via python command"
            return
        }
    }
    Fail "Python 3.12.x was not found. Please follow the README instructions to install it."
}

# FIXED: Renamed parameter to $PythonArgs to avoid shadowing the automatic $args variable
function Invoke-BootstrapPython([string[]]$PythonArgs) {
    if ($script:PythonBootstrapCmd.Count -eq 0) { Fail "Python command not set." }

    $exe = $script:PythonBootstrapCmd[0]
    $prefixArgs = if ($script:PythonBootstrapCmd.Count -gt 1) { $script:PythonBootstrapCmd[1..($script:PythonBootstrapCmd.Count - 1)] } else { @() }

    # Pass arguments explicitly
    & $exe @prefixArgs @PythonArgs
}

function Create-Venv {
    if (Test-Path $VenvPython) {
        Log "Using existing virtual environment: $VenvDir"
        return
    }
    if (Test-Path $VenvDir) {
        Log "Cleaning up invalid .venv folder..."
        Remove-Item -Recurse -Force $VenvDir
    }

    Log "Creating virtual environment at $VenvDir"
    $exe = $script:PythonBootstrapCmd[0]
    $allArgs = @()
    if ($script:PythonBootstrapCmd.Count -gt 1) {
        $allArgs += $script:PythonBootstrapCmd[1..($script:PythonBootstrapCmd.Count - 1)]
    }
    $allArgs += "-m", "venv", $VenvDir
    & $exe $allArgs
}

function Install-Dependencies {
    if (-not (Test-Path $ReqFile)) { Fail "Missing requirements file: $ReqFile" }

    Log "Upgrading pip, setuptools, wheel"
    & $VenvPython -m pip install --upgrade pip setuptools wheel

    Log "Installing dependencies from $ReqFile"
    & $VenvPython -m pip install -r $ReqFile
}

function Ensure-UserWorkDir {
    if (-not (Test-Path $UserWorkDir)) {
        New-Item -ItemType Directory -Path $UserWorkDir -Force | Out-Null
    }
    Log "Ensured student workspace: $UserWorkDir"
}

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
    Log "Install complete. Next: .\build-helper.ps1 start"
}

Main