#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Resolve absolute paths so script works from any current directory.
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path

$BuildHelper = Join-Path $RepoRoot "build-helper.ps1"
$ShortcutName = "Math Notebook.lnk"

# Start Menu and Desktop shortcut targets.
$StartMenuPrograms = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
$StartMenuShortcut = Join-Path $StartMenuPrograms $ShortcutName
$DesktopShortcut = Join-Path ([Environment]::GetFolderPath("Desktop")) $ShortcutName

function Log([string]$Message) {
    Write-Host "[math-notebook] $Message"
}

function Fail([string]$Message) {
    throw "[math-notebook] ERROR: $Message"
}

function New-Shortcut([string]$ShortcutPath) {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($ShortcutPath)

    # Use powershell.exe as the launcher target and call build-helper.ps1 start command.
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$BuildHelper`" start"
    $shortcut.WorkingDirectory = $RepoRoot
    $shortcut.IconLocation = "shell32.dll,220"
    $shortcut.Description = "Start JupyterLab for math-notebook"

    $shortcut.Save()
}

function Main {
    if (-not (Test-Path $BuildHelper)) {
        Fail "Missing build helper: $BuildHelper"
    }

    New-Item -ItemType Directory -Path $StartMenuPrograms -Force | Out-Null

    Log "Installing Start Menu shortcut"
    New-Shortcut -ShortcutPath $StartMenuShortcut

    Log "Installing Desktop shortcut"
    New-Shortcut -ShortcutPath $DesktopShortcut

    Log "Launcher installed"
    Log "Start Menu: $StartMenuShortcut"
    Log "Desktop: $DesktopShortcut"
}

Main
