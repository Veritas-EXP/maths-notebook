# Math Notebook

Simple, homeschool-friendly JupyterLab setup for math learning (ages 10-14) using open Python tools instead of proprietary software.

Primary target: **Linux Mint**  
Secondary target: **Windows** (PowerShell support planned)

---

## Goals

- Make setup easy and repeatable.
- Keep student work separate from teacher material.
- Start Jupyter with one command (or desktop launcher).
- Teach practical math tools: numerical, symbolic, and plotting workflows.

---

## Current Status

Implemented now:
- Linux installer script (`scripts/bash/install.sh`)
- Linux start script (`scripts/bash/start.sh`)
- Linux desktop launcher installer (`scripts/bash/install-launcher.sh`)
- Unified Linux command entrypoint (`build-helper.sh`)
- Dependency file (`dependencies/requirements.txt`)

Planned next:
- Windows PowerShell entrypoint (`build-helper.ps1`)
- Windows PowerShell install/start scripts
- Initial teacher example notebooks under `notebooks/examples/`
- Shared helper module at `python/math_tools.py`

---

## Python Baseline

This project is locked to **Python 3.12.x**.

Why:
- Stable ecosystem support for Jupyter + scientific stack.
- Lower setup friction on Linux Mint.
- Good balance of stability and modern features.

---

## Core Packages (and Why)

- `numpy`
  - Fast numeric arrays and matrix-style calculations.

- `scipy`
  - Scientific utilities (equation solving, interpolation, optimization, stats helpers).

- `sympy`
  - Symbolic math (exact expressions, algebra simplification, derivatives/integrals).

- `matplotlib`
  - Graphing functions and plotting assignment figures.

- `jupyterlab`
  - Main notebook interface for daily student use.

- `ipykernel`
  - Connects the project `.venv` to Jupyter kernels.

- `pandas` *(optional but recommended)*
  - Table/data workflows for statistics notebooks.

- `ipympl` *(optional)*
  - Interactive matplotlib backend in JupyterLab.

---

## Repository Layout (Current Plan)

```text
math-notebook/
├── AGENTS.md
├── README.md
├── .gitignore
├── build-helper.sh
├── build-helper.ps1                 # planned
│
├── dependencies/
│   └── requirements.txt
│
├── scripts/
│   ├── bash/
│   │   ├── install.sh
│   │   ├── start.sh
│   │   └── install-launcher.sh
│   └── powershell/                  # planned
│       ├── install.ps1
│       ├── start.ps1
│       └── install-launcher.ps1
│
├── notebooks/
│   └── examples/                    # planned content
│
├── python/
│   └── math_tools.py                # planned
│
└── user-work/
    └── ... student notebooks
```

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

---

## `build-helper.sh` Commands

- `init`
  - Creates/updates `.venv`
  - Installs dependencies from `dependencies/requirements.txt`
  - Registers Jupyter kernel `Python (math-notebook)`

- `start`
  - Starts JupyterLab with project root visible
  - Opens directly in `user-work/`
  - Makes local `python/` helpers importable

- `launcher`
  - Installs Linux desktop/menu launcher for one-click startup

- `help`
  - Prints command usage

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

## Windows Setup (PowerShell)

This project supports Windows through `build-helper.ps1` and scripts in `scripts/powershell/`.

### 1) Install Python 3.12 (if missing)

Check if Python launcher is available:

```powershell
py -3.12 --version
```

If that fails, install Python 3.12 with `winget`:

```powershell
winget install --id Python.Python.3.12 --source winget --accept-source-agreements --accept-package-agreements
```

After install, close and reopen PowerShell, then verify again:

```powershell
py -3.12 --version
```

### 2) If `py` still not found, add Python to PATH

Run this in PowerShell (adjust `Python312` if your install path differs):

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

Then verify:

```powershell
py -3.12 --version
```

### 3) Allow local project scripts (one-time)

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### 4) Initialize the project

From repo root:

```powershell
.\build-helper.ps1 init
```

This creates `.venv`, installs dependencies, and registers the Jupyter kernel.

### 5) Start JupyterLab

```powershell
.\build-helper.ps1 start
```

### 6) Optional: install launcher shortcuts

```powershell
.\build-helper.ps1 launcher
```

This creates Start Menu and Desktop shortcuts for one-click startup.

### Quick Troubleshooting

- `py` command not found:
  - Reopen PowerShell after installation.
  - Confirm Python Launcher was installed.
  - Use the PATH snippet above.
- Script blocked by policy:
  - Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.
- `.venv` issues:
  - Delete `.venv` and run `.\build-helper.ps1 init` again.
