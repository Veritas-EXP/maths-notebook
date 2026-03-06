#!/usr/bin/env bash
set -euo pipefail

# Resolve absolute paths so the script works from any current directory.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "${script_dir}/../.." && pwd -P)"

# Project paths.
venv_dir="${repo_root}/.venv"
venv_python="${venv_dir}/bin/python"
user_work_dir="${repo_root}/user-work"
project_python_dir="${repo_root}/python"

log() {
  printf '[math-notebook] %s\n' "$1"
}

fail() {
  printf '[math-notebook] ERROR: %s\n' "$1" >&2
  exit 1
}

# Verify the virtual environment exists and is usable.
require_venv() {
  [[ -x "${venv_python}" ]] || fail "Missing virtual environment. Run ./build-helper.sh install first."
}

# Ensure the student workspace exists before Jupyter starts.
ensure_user_work_dir() {
  mkdir -p "${user_work_dir}"
}

# Launch JupyterLab with project root visible, and user-work as default landing page.
start_jupyter() {
  # Make local helper modules importable in notebooks.
  if [[ -n "${PYTHONPATH:-}" ]]; then
    export PYTHONPATH="${project_python_dir}:${PYTHONPATH}"
  else
    export PYTHONPATH="${project_python_dir}"
  fi

  log "Starting JupyterLab"
  "${venv_python}" -m jupyter lab \
    --ServerApp.root_dir="${repo_root}" \
    --ServerApp.default_url="/lab/tree/user-work" \
    --ServerApp.open_browser=true \
    "$@"
}

main() {
  require_venv
  ensure_user_work_dir
  start_jupyter "$@"
}

main "$@"
