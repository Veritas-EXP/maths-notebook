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
  init                Create/update .venv and install all dependencies
  start               Start JupyterLab (opens in user-work)
  launcher            Install desktop app launcher on Linux
  uninstall           Remove local install artifacts (keeps user-work)
  help                Show this help text

Examples:
  ./build-helper.sh init
  ./build-helper.sh start
  ./build-helper.sh launcher
  ./build-helper.sh uninstall
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
    launcher|install-launcher)
      run_script "install-launcher.sh" "$@"
      ;;
    uninstall|remove)
      run_script "uninstall.sh" "$@"
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
