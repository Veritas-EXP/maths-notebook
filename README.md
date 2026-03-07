# Math Notebook

Simple, homeschool-friendly JupyterLab setup for math learning (ages 10-14) using open Python tools instead of proprietary software.

Primary target: **Linux Mint**  
Secondary target: **Windows (PowerShell)**

---

## Goals

- Make setup easy and repeatable.
- Keep student work separate from teacher material.
- Start Jupyter with one command (or desktop launcher).
- Teach practical math tools: numerical, symbolic, and plotting workflows.

---

## Current Status

Implemented now:
- Linux helper and scripts:
  - `build-helper.sh`
  - `scripts/bash/install.sh`
  - `scripts/bash/start.sh`
  - `scripts/bash/install-launcher.sh`
  - `scripts/bash/uninstall.sh`
- Windows helper and scripts:
  - `build-helper.ps1`
  - `scripts/powershell/install.ps1`
  - `scripts/powershell/start.ps1`
  - `scripts/powershell/install-launcher.ps1`
  - `scripts/powershell/uninstall.ps1`
- Dependency lock file:
  - `dependencies/requirements.txt`
- Teacher notebooks:
  - `notebooks/examples/00_jupyter_quickstart.ipynb`
  - `notebooks/examples/01_notebook_tutorial.ipynb`

---

## Python Baseline

This project is locked to **Python 3.12.x**.

Why:
- Stable ecosystem support for Jupyter + scientific stack.
- Lower setup friction on Linux Mint and Windows.
- Good balance of stability and modern features.

---

## Core Packages (and Why)

Packages are pinned in `dependencies/requirements.txt`.  
Main teaching-focused packages:

- `numpy`
  - Fast numeric arrays and matrix-style calculations.
- `scipy`
  - Scientific utilities (equation solving, interpolation, optimization, stats helpers).
- `sympy`
  - Symbolic math (exact expressions, simplification, derivatives/integrals).
- `matplotlib`
  - Graphing functions and plotting assignment figures.
- `jupyterlab`
  - Main notebook interface for daily student use.
- `ipykernel`
  - Connects the project `.venv` to a named Jupyter kernel.
- `pandas`
  - Data tables and statistics workflows in notebooks.
- `ipympl`
  - Interactive matplotlib backend in Jupyter.

---

## Repository Layout (Current)

```text
math-notebook/
├── AGENTS.md
├── README.md
├── build-helper.sh
├── build-helper.ps1
├── dependencies/
│   └── requirements.txt
├── notebooks/
│   └── examples/
│       ├── 00_jupyter_quickstart.ipynb
│       └── 01_notebook_tutorial.ipynb
└── scripts/
    ├── bash/
    │   ├── install.sh
    │   ├── start.sh
    │   ├── install-launcher.sh
    │   └── uninstall.sh
    └── powershell/
        ├── install.ps1
        ├── start.ps1
        ├── install-launcher.ps1
        └── uninstall.ps1
```

`user-work/` is student-owned and created as needed by install/start scripts.

---

## Linux Mint Quick Start

From repo root:

```bash
./build-helper.sh init
./build-helper.sh start
```

Install launcher (one-time):

```bash
./build-helper.sh launcher
```

Uninstall local program artifacts:

```bash
./build-helper.sh uninstall
# or non-interactive
./build-helper.sh uninstall --yes
```

---

## Windows PowerShell Python Setup Guide

### 1) Check Python 3.12

```powershell
py -3.12 --version
```

### 2) Install Python 3.12 (if missing)

```powershell
winget install --id Python.Python.3.12 --source winget --accept-source-agreements --accept-package-agreements
```

Close and reopen PowerShell, then verify again:

```powershell
py -3.12 --version
```

### 3) If `py` is unavailable, add Python to PATH

```powershell
$pyRoot = "$env:LocalAppData\Programs\Python\Python312"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($userPath -notlike "*$pyRoot*") {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$userPath;$pyRoot;$pyRoot\Scripts",
        "User"
    )
}

# Refresh PATH in current session
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [Environment]::GetEnvironmentVariable("Path", "User")
```

Verify:

```powershell
python --version
```

### 4) Allow local scripts (one-time)

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

---

## Windows Quick Start (PowerShell)

From repo root:

```powershell
.\build-helper.ps1 init
.\build-helper.ps1 start
```

Optional launcher install:

```powershell
.\build-helper.ps1 launcher
```

Uninstall local program artifacts:

```powershell
.\build-helper.ps1 uninstall
# or non-interactive
.\build-helper.ps1 uninstall --yes
```

---

## Command Reference

Linux `build-helper.sh`:
- `init` / `install`: create or update `.venv`, install dependencies, register kernel
- `start`: start JupyterLab in `user-work/`
- `launcher` / `install-launcher`: install Linux desktop launcher
- `uninstall` / `remove`: remove local install artifacts
- `help`: show usage

Windows `build-helper.ps1`:
- `init` / `install`: create or update `.venv`, install dependencies, register kernel
- `start`: start JupyterLab in `user-work/`
- `launcher`: install Start Menu + Desktop shortcut
- `uninstall` / `remove`: remove local install artifacts
- `help`: show usage

---

## Uninstall Scope

Uninstall removes:
- Project virtual environment (`.venv`)
- Jupyter kernel (`math-notebook`)
- Repo-local caches (`__pycache__`, `.pytest_cache`, `.ipynb_checkpoints`)
- Launcher files created by this project

Uninstall preserves:
- `user-work/` (student notebooks and files)

---

## Student vs Teacher Folders

- `notebooks/examples/` = teacher-owned reference notebooks
- `user-work/` = student assignments and personal notebooks

Recommended workflow:
1. Open an example notebook.
2. Copy it into `user-work/`.
3. Solve tasks in the copied version.

---

## Version Control Policy

Student work should not be committed by default.

Suggested `.gitignore`:

```gitignore
.venv/
__pycache__/
.ipynb_checkpoints/
user-work/*
!user-work/README.md
```

---

## Quick Troubleshooting

- `py` command not found on Windows:
  - Reopen PowerShell after Python installation.
  - Verify installation with `python --version`.
  - Add Python 3.12 paths using the setup snippet above.
- Python is not 3.12.x:
  - Run `py -3.12 --version`.
  - If needed, reinstall Python 3.12 and reopen shell.
- Script blocked by policy on Windows:
  - Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.
- Missing or broken `.venv`:
  - Run uninstall, then install again:
    - Linux: `./build-helper.sh uninstall --yes && ./build-helper.sh init`
    - Windows: `.\build-helper.ps1 uninstall --yes; .\build-helper.ps1 init`
- Jupyter kernel issues:
  - Re-run install to re-register kernel:
    - Linux: `./build-helper.sh init`
    - Windows: `.\build-helper.ps1 init`
