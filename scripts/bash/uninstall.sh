#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "${script_dir}/../.." && pwd -P)"

venv_dir="${repo_root}/.venv"
venv_python="${venv_dir}/bin/python"
kernel_name="math-notebook"

launcher_script_path="${HOME}/.local/bin/math-notebook-launch"
applications_dir="${HOME}/.local/share/applications"
desktop_entry_path="${applications_dir}/math-notebook.desktop"
desktop_shortcut_path="${HOME}/Desktop/Math Notebook.desktop"
kernel_dir="${HOME}/.local/share/jupyter/kernels/${kernel_name}"
user_work_dir="${repo_root}/user-work"

assume_yes=false

log() {
  printf '[math-notebook] %s\n' "$1"
}

fail() {
  printf '[math-notebook] ERROR: %s\n' "$1" >&2
  exit 1
}

remove_path() {
  local path="$1"
  if [[ -e "${path}" || -L "${path}" ]]; then
    rm -rf -- "${path}"
    log "Removed: ${path}"
  else
    log "Already absent: ${path}"
  fi
}

confirm() {
  local answer
  printf 'Proceed with uninstall? [y/N]: '
  read -r answer
  case "${answer}" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

remove_kernel() {
  local removed=false

  # Try through project venv first.
  if [[ -x "${venv_python}" ]]; then
    if "${venv_python}" -m jupyter kernelspec uninstall -f "${kernel_name}" >/dev/null 2>&1; then
      log "Removed Jupyter kernel: ${kernel_name}"
      removed=true
    fi
  fi

  # Fallback to system jupyter.
  if ! $removed && command -v jupyter >/dev/null 2>&1; then
    if jupyter kernelspec uninstall -f "${kernel_name}" >/dev/null 2>&1; then
      log "Removed Jupyter kernel: ${kernel_name}"
      removed=true
    fi
  fi

  # Final fallback: direct path removal.
  if [[ -d "${kernel_dir}" ]]; then
    rm -rf -- "${kernel_dir}"
    log "Removed kernel directory: ${kernel_dir}"
    removed=true
  fi

  if ! $removed; then
    log "Jupyter kernel already absent: ${kernel_name}"
  fi
}

remove_repo_caches() {
  log "Removing repo-local cache folders (excluding user-work)"

  while IFS= read -r -d '' path; do
    remove_path "${path}"
  done < <(
    find "${repo_root}" \
      \( -path "${venv_dir}" -o -path "${user_work_dir}" \) -prune -o \
      -type d \( -name '__pycache__' -o -name '.pytest_cache' -o -name '.ipynb_checkpoints' \) \
      -print0
  )
}

remove_linux_launcher_files() {
  remove_path "${launcher_script_path}"
  remove_path "${desktop_entry_path}"
  remove_path "${desktop_shortcut_path}"

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${applications_dir}" >/dev/null 2>&1 || true
  fi
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes)
        assume_yes=true
        shift
        ;;
      *)
        fail "Unknown option: $1"
        ;;
    esac
  done

  [[ -n "${repo_root}" && "${repo_root}" != "/" ]] || fail "Invalid repo root."

  log "Uninstall target: ${repo_root}"
  log "Will remove: .venv, kernel '${kernel_name}', repo caches, Linux launcher files."
  log "Will preserve: user-work."

  if ! $assume_yes && ! confirm; then
    log "Cancelled."
    exit 0
  fi

  remove_kernel
  remove_path "${venv_dir}"
  remove_repo_caches
  remove_linux_launcher_files

  log "Uninstall complete."
}

main "$@"
