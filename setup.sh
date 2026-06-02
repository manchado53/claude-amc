#!/usr/bin/env bash
#
# setup.sh — point CLAUDE.machine.md at this machine's env file.
#
# Copies machines/<machine>.md -> CLAUDE.machine.md (a COPY, never a move/delete,
# so every machine's source file stays tracked and backed up in git).
#
# Usage:
#   ./setup.sh            # auto-detect this machine; ask if unsure
#   ./setup.sh rosie      # force a specific machine (any machines/<name>.md)
#   ./setup.sh laptop
#
# Runs under bash: native on Linux/macOS, and under Git Bash or WSL on Windows.

set -euo pipefail

# Resolve this script's own dir, so it works no matter where it's invoked from.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINES_DIR="$DIR/machines"
LIVE="$DIR/CLAUDE.machine.md"

list_machines() {
  # Print available machine names (filenames in machines/ without .md).
  for f in "$MACHINES_DIR"/*.md; do
    [ -e "$f" ] || continue
    basename "$f" .md
  done
}

detect_machine() {
  # Echo a guessed machine name, or empty string if unsure.
  local host os
  host="$(hostname 2>/dev/null || echo "${HOSTNAME:-}")"
  host="$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')"
  os="$(uname -s 2>/dev/null || echo unknown)"

  # Rosie nodes use the dh- prefix (e.g. dh-mgmt2); also match obvious markers.
  case "$host" in
    dh-*|*rosie*|*msoe*|*hpc*) echo "rosie"; return ;;
  esac

  # Windows shells (Git Bash / MSYS / Cygwin) report MINGW*/MSYS*/CYGWIN*.
  case "$os" in
    MINGW*|MSYS*|CYGWIN*) echo "laptop"; return ;;
  esac

  echo ""   # unsure
}

# 1. Pick the machine: explicit arg wins, else auto-detect, else ask.
machine="${1:-}"
if [ -z "$machine" ]; then
  machine="$(detect_machine)"
  if [ -n "$machine" ]; then
    echo "Detected machine: $machine (host=$(hostname 2>/dev/null), os=$(uname -s 2>/dev/null))"
  fi
fi

if [ -z "$machine" ]; then
  echo "Could not auto-detect this machine. Available:"
  list_machines | sed 's/^/  - /'
  printf "Which machine? "
  read -r machine
fi

# 2. Validate the source file exists.
SRC="$MACHINES_DIR/$machine.md"
if [ ! -f "$SRC" ]; then
  echo "ERROR: no env file for '$machine' (expected $SRC)." >&2
  echo "Available machines:" >&2
  list_machines | sed 's/^/  - /' >&2
  exit 1
fi

# 3. Copy (never move) into the live, gitignored file the import reads.
cp "$SRC" "$LIVE"
echo "OK: CLAUDE.machine.md now mirrors machines/$machine.md"
echo "(source files in machines/ are untouched and stay tracked in git)"
