#!/usr/bin/env pwsh
param(
    [switch]$Yes,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path

$VenvDir = Join-Path $RepoRoot ".venv"
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$UserWorkDir = Join-Path $RepoRoot "user-work"
$KernelName = "math-notebook"
$KernelDir = Join-Path $env:APPDATA "jupyter\kernels\$KernelName"

$ShortcutName = "Math Notebook.lnk"
$StartMenuPrograms = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
$StartMenuShortcut = Join-Path $StartMenuPrograms $ShortcutName
$DesktopShortcut = Join-Path ([Environment]::GetFolderPath("Desktop")) $ShortcutName

function Log([string]$Message) {
    Write-Host "[math-notebook] $Message"
}

function Fail([string]$Message) {
    throw "[math-notebook] ERROR: $Message"
}

function Remove-PathIfExists([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
        Log "Removed: $Path"
    } else {
        Log "Already absent: $Path"
    }
}

function Confirm-Uninstall {
    $answer = Read-Host "Proceed with uninstall? [y/N]"
    return $answer -match "^(y|yes)$"
}

function Remove-Kernel {
    $removed = $false

    # Try through project venv first.
    if (Test-Path -LiteralPath $VenvPython) {
        try {
            & $VenvPython -m jupyter kernelspec uninstall -f $KernelName *> $null
            if ($LASTEXITCODE -eq 0) {
                Log "Removed Jupyter kernel: $KernelName"
                $removed = $true
            }
        } catch {}
    }

    # Fallback to system jupyter.
    if (-not $removed) {
        $jupyterCmd = Get-Command jupyter -ErrorAction SilentlyContinue
        if ($jupyterCmd) {
            try {
                & jupyter kernelspec uninstall -f $KernelName *> $null
                if ($LASTEXITCODE -eq 0) {
                    Log "Removed Jupyter kernel: $KernelName"
                    $removed = $true
                }
            } catch {}
        }
    }

    # Final fallback: direct path removal.
    if (Test-Path -LiteralPath $KernelDir) {
        Remove-Item -LiteralPath $KernelDir -Recurse -Force
        Log "Removed kernel directory: $KernelDir"
        $removed = $true
    }

    if (-not $removed) {
        Log "Jupyter kernel already absent: $KernelName"
    }
}

function Remove-RepoCaches {
    Log "Removing repo-local cache folders (excluding user-work)"

    $userWorkPrefix = ($UserWorkDir.TrimEnd('\') + "\").ToLowerInvariant()
    $venvPrefix = ($VenvDir.TrimEnd('\') + "\").ToLowerInvariant()

    $targets = Get-ChildItem -Path $RepoRoot -Directory -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -in @("__pycache__", ".pytest_cache", ".ipynb_checkpoints") } |
        Where-Object {
            $full = ($_.FullName.TrimEnd('\') + "\").ToLowerInvariant()
            -not $full.StartsWith($userWorkPrefix) -and -not $full.StartsWith($venvPrefix)
        }

    foreach ($dir in $targets) {
        Remove-PathIfExists -Path $dir.FullName
    }
}

function Parse-ExtraArgs {
    foreach ($arg in $ExtraArgs) {
        if ($arg -eq "--yes") {
            $script:Yes = $true
            continue
        }
        Fail "Unknown option: $arg"
    }
}

function Main {
    Parse-ExtraArgs

    if (-not (Test-Path -LiteralPath $RepoRoot)) {
        Fail "Invalid repo root: $RepoRoot"
    }

    Log "Uninstall target: $RepoRoot"
    Log "Will remove: .venv, kernel '$KernelName', repo caches, Windows launcher files."
    Log "Will preserve: user-work."

    if (-not $Yes) {
        if (-not (Confirm-Uninstall)) {
            Log "Cancelled."
            return
        }
    }

    Remove-Kernel
    Remove-PathIfExists -Path $VenvDir
    Remove-RepoCaches
    Remove-PathIfExists -Path $StartMenuShortcut
    Remove-PathIfExists -Path $DesktopShortcut

    Log "Uninstall complete."
}

Main
