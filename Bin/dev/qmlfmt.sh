#!/usr/bin/env -S bash
set -euo pipefail

# Find qmlformat in PATH
if ! command -v qmlformat >/dev/null 2>&1; then
    echo "Error: 'qmlformat' not found in PATH." >&2
    echo "On NixOS, install it via: nix-shell -p qt6.qttools" >&2
    exit 1
fi

format_file() {
    qmlformat -w 2 -W 360 -S --semicolon-rule always -i "$1" \
        || { echo "Failed: $1" >&2; return 1; }
}

export -f format_file

mapfile -t all_files < <(find "${1:-.}" -name "*.qml" -type f)
[ ${#all_files[@]} -eq 0 ] && { echo "No QML files found"; exit 0; }

echo "Formatting ${#all_files[@]} files..."
printf '%s\0' "${all_files[@]}" |
    xargs -0 -P "${QMLFMT_JOBS:-$(nproc)}" -I {} bash -c 'format_file "$@"' _ {} \
    && echo "Done" || { echo "Errors occurred" >&2; exit 1; }
