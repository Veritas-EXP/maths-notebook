#!/usr/bin/env bash
set -euo pipefail

# Resolve repo root from this script location.
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "${script_dir}/../.." && pwd -P)"

launcher_script_dir="${HOME}/.local/bin"
launcher_script_path="${launcher_script_dir}/math-notebook-launch"
applications_dir="${HOME}/.local/share/applications"
desktop_entry_path="${applications_dir}/math-notebook.desktop"
desktop_shortcut_path="${HOME}/Desktop/Math Notebook.desktop"
build_helper="${repo_root}/build-helper.sh"

log() {
  printf '[math-notebook] %s\n' "$1"
}

fail() {
  printf '[math-notebook] ERROR: %s\n' "$1" >&2
  exit 1
}

[[ -x "${build_helper}" ]] || fail "Missing executable build helper: ${build_helper}"

# Create a stable local launcher script used by the desktop entry.
mkdir -p "${launcher_script_dir}"
cat > "${launcher_script_path}" <<EOF
#!/usr/bin/env bash
set -euo pipefail
cd "${repo_root}"
exec "${build_helper}" start "\$@"
EOF
chmod +x "${launcher_script_path}"

# Install desktop menu entry.
mkdir -p "${applications_dir}"
cat > "${desktop_entry_path}" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Math Notebook
Comment=Start JupyterLab for math-notebook
Exec=${launcher_script_path}
Icon=accessories-calculator
Terminal=false
Categories=Education;Science;
StartupNotify=true
EOF
chmod 644 "${desktop_entry_path}"

# Optional: also place a shortcut on the desktop.
if [[ -d "${HOME}/Desktop" ]]; then
  cp "${desktop_entry_path}" "${desktop_shortcut_path}"
  chmod +x "${desktop_shortcut_path}"
fi

# Refresh desktop database if available.
if command -v update-desktop-database >/dev/null 2>&1; then
  if ! update-desktop-database "${applications_dir}"; then
    log "Could not refresh desktop database automatically."
  fi
fi

log "Launcher installed."
log "Menu entry: ${desktop_entry_path}"
if [[ -f "${desktop_shortcut_path}" ]]; then
  log "Desktop shortcut: ${desktop_shortcut_path}"
fi
