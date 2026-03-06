# Math Notebook (Homeschool Setup)

A simple JupyterLab setup for homeschooled students (ages 10-14) to learn practical math tools with Python instead of proprietary software.

Main libraries:
- `numpy`
- `sympy`
- `matplotlib`
- `scipy`

Primary target: **Linux Mint**
Secondary support: **Windows** (via `.bat` launcher)

## Project Goals

- Keep setup easy for non-technical users.
- Separate teacher examples from student assignments.
- Make daily usage one click (desktop launcher), not terminal-heavy.
- Build basic computational math habits with open tools.

## Planned Repository Structure

```text
math-notebook/
├── README.md
├── requirements.txt
├── install.sh
├── start.sh
├── launchers/
│   ├── install_launcher_linux.sh
│   └── start_math_notebook.bat
├── notebooks/
│   └── examples/
│       ├── calculator.ipynb
│       ├── algebra.ipynb
│       ├── graphing.ipynb
│       └── statistics.ipynb
├── python/
│   └── math_tools.py
├── user-work/
│   └── README.md
└── .gitignore
```

## Folder Intent

- `notebooks/examples/`: teacher-owned reference notebooks.
- `user-work/`: student notebooks, assignments, rough work.
- `python/math_tools.py`: reusable helper functions.
- `launchers/`: scripts for desktop launch shortcuts.

## Why This Structure

- Students avoid accidental edits to teacher templates.
- Work is easy to find (`user-work/` behaves like a school documents folder).
- The setup remains transparent: plain Python environment + JupyterLab.

## Requirements

- Python 3.10+ (3.11 recommended)
- Linux Mint (or compatible Linux)
- A modern browser

## Core Python Packages (and Why We Use Them)

This project uses a small set of core packages so students can learn practical math workflows in one place.

- `numpy`
  - Purpose: fast numerical arrays and core numerical operations.
  - Typical use: vectors, matrices, and numeric calculations.

- `scipy`
  - Purpose: scientific tools built on top of NumPy.
  - Typical use: equation solving, optimization, interpolation, and stats helpers.

- `sympy`
  - Purpose: symbolic mathematics (exact expressions, not only decimal approximations).
  - Typical use: simplify/factor expressions, symbolic derivatives and integrals.

- `matplotlib`
  - Purpose: plotting and graphing.
  - Typical use: graph functions, visualize data, produce assignment figures.

- `pandas` *(optional but recommended)*
  - Purpose: table/data handling.
  - Typical use: statistics datasets and simple data analysis.

- `jupyterlab`
  - Purpose: the notebook interface students use every day.
  - Typical use: combine explanations, calculations, and plots in one document.

- `ipykernel`
  - Purpose: connects the project Python environment to Jupyter.
  - Typical use: ensures notebooks run with the correct `.venv` packages.

- `ipympl` *(optional)*
  - Purpose: interactive Matplotlib backend in JupyterLab.
  - Typical use: zooming and panning graphs during lessons.

### Why this set?

- Covers the full learning loop: calculate, reason symbolically, visualize, and document.
- Keeps setup lightweight and stable on Linux Mint.
- Builds skills that transfer to higher-level STEM study.

## Linux Mint Setup (First Time)

From the project root:

```bash
bash install.sh
```

This should:
1. Create `.venv`
2. Upgrade `pip`
3. Install dependencies from `requirements.txt`
4. Register a Jupyter kernel for this project (optional but recommended)

## Linux Mint Daily Start

From the project root:

```bash
bash start.sh
```

Expected behavior:
- Activates `.venv`
- Starts JupyterLab
- Opens browser automatically
- Uses `user-work/` as default place for student files

## Linux Mint Desktop Launcher (No Terminal)

Install launcher once:

```bash
bash launchers/install_launcher_linux.sh
```

Expected result:
- Creates a desktop/menu entry (via `.desktop` file)
- Students start Math Notebook by clicking the app icon

## Windows Quick Start (Basic Support)

From project root in Command Prompt:

```bat
py -m venv .venv
.\.venv\Scripts\python -m pip install --upgrade pip
.\.venv\Scripts\pip install -r requirements.txt
launchers\start_math_notebook.bat
```

You can make a desktop shortcut to `launchers\start_math_notebook.bat`.

## Student Workflow

1. Open Math Notebook.
2. Browse `notebooks/examples/` for lesson examples.
3. Create or copy notebooks into `user-work/`.
4. Save work frequently.

## Teacher Workflow

- Keep canonical lessons in `notebooks/examples/`.
- Ask students to copy notebooks into `user-work/` before editing.
- Keep shared helper functions in `python/math_tools.py`.

## Version Control Note

`user-work/` should be ignored in git so student files do not pollute commits.

Typical `.gitignore` pattern:

```gitignore
user-work/*
!user-work/README.md
```

## Suggested Next Build Steps

1. Create `install.sh` and `start.sh`.
2. Add starter notebooks in `notebooks/examples/`.
3. Add `python/math_tools.py` with beginner-friendly utilities.
4. Add Linux Mint launcher installer script.
5. Add Windows `.bat` launcher.
