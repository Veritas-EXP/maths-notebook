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

## Notes for Windows

Windows support will use **PowerShell** (`build-helper.ps1`) rather than `.bat` logic.  
The behavior will match Linux commands: `init`, `start`, `launcher`.
