#!/usr/bin/env bash
set -euo pipefail

# Resolve absolute paths so the script works no matter where it is called from.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "${script_dir}/../.." && pwd -P)"

# Project paths and constants.
venv_dir="${repo_root}/.venv"
req_file="${repo_root}/dependencies/requirements.txt"
user_work_dir="${repo_root}/user-work"
kernel_name="math-notebook"
kernel_display_name="Python (math-notebook)"

log() {
  printf '[math-notebook] %s\n' "$1"
}

fail() {
  printf '[math-notebook] ERROR: %s\n' "$1" >&2
  exit 1
}

# Ensure Python is installed and matches the project baseline (3.12.x).
require_python_312() {
  command -v python3 >/dev/null 2>&1 || fail "python3 not found. Install Python 3.12.x first."

  local major minor micro
  read -r major minor micro < <(python3 -c 'import sys; print(*sys.version_info[:3])')

  if [[ "$major" -ne 3 || "$minor" -ne 12 ]]; then
    fail "Detected Python ${major}.${minor}.${micro}. This project requires Python 3.12.x."
  fi

  log "Using Python ${major}.${minor}.${micro}"
}

# Create the virtual environment if it does not exist yet.
create_venv() {
  if [[ -x "${venv_dir}/bin/python" ]]; then
    log "Using existing virtual environment: ${venv_dir}"
    return
  fi

  if [[ -e "${venv_dir}" ]]; then
    fail "Found ${venv_dir}, but it is not a valid venv. Remove it and run again."
  fi

  log "Creating virtual environment at ${venv_dir}"
  python3 -m venv "${venv_dir}"
}

# Install and upgrade project dependencies in the venv.
install_dependencies() {
  [[ -f "${req_file}" ]] || fail "Missing requirements file: ${req_file}"

  log "Upgrading pip, setuptools, wheel"
  "${venv_dir}/bin/python" -m pip install --upgrade pip setuptools wheel

  log "Installing dependencies from ${req_file}"
  "${venv_dir}/bin/python" -m pip install -r "${req_file}"
}

# Ensure the student workspace directory exists.
ensure_user_work_dir() {
  mkdir -p "${user_work_dir}"
  log "Ensured student workspace: ${user_work_dir}"
}

# Register a named Jupyter kernel so notebooks can use this exact environment.
register_ipykernel() {
  log "Registering Jupyter kernel: ${kernel_display_name}"
  "${venv_dir}/bin/python" -m ipykernel install --user \
    --name "${kernel_name}" \
    --display-name "${kernel_display_name}"
}

# Main install flow.
main() {
  log "Starting install"
  require_python_312
  create_venv
  install_dependencies
  ensure_user_work_dir
  register_ipykernel
  log "Install complete"
  log "Next: ./build-helper.sh start"
}

main "$@"
