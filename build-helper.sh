#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="${script_dir}"

log() {
  printf '[math-notebook] %s\n' "$1"
}

usage() {
  cat <<'EOF'
Usage:
  ./build-helper.sh <command> [args]

Commands:
  init, install       Create/update .venv and install dependencies
  start               Start JupyterLab
  install-launcher    Install Linux desktop launcher
  help                Show this help
EOF
}

fail_with_help() {
  printf '[math-notebook] ERROR: %s\n\n' "$1" >&2
  usage >&2
  exit 1
}

run_script() {
  local script_name="$1"
  shift
  local script_path="${repo_root}/scripts/bash/${script_name}"

  [[ -f "${script_path}" ]] || fail_with_help "Missing script: ${script_path}"

  if ! bash "${script_path}" "$@"; then
    fail_with_help "Command failed: ${script_name}"
  fi
}

main() {
  local cmd="help"
  if [[ $# -gt 0 ]]; then
    cmd="$1"
    shift
  fi

  case "${cmd}" in
    init|install)
      run_script "install.sh" "$@"
      ;;
    start)
      run_script "start.sh" "$@"
      ;;
    install-launcher)
      run_script "install-launcher.sh" "$@"
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      fail_with_help "Unknown command: ${cmd}"
      ;;
  esac
}

main "$@"
