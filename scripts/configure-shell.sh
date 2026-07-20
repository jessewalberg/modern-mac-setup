#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
umask 077

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SNIPPET="$ROOT_DIR/snippets/zshrc"
TARGET="${ZDOTDIR:-$HOME}/.zshrc"
MARKER='# >>> modern-mac-setup >>>'
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: ./scripts/configure-shell.sh [--dry-run]

Appends one managed block to ~/.zshrc after creating a timestamped backup.
Existing managed blocks are left untouched so reruns are non-destructive.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      printf '[ERROR] Unknown option: %s\n' "$1" >&2
      exit 1
      ;;
  esac
  shift
done

[[ "$(uname -s)" == 'Darwin' ]] || {
  printf '[ERROR] This shell snippet is intended for macOS.\n' >&2
  exit 1
}
[[ "$EUID" -ne 0 ]] || {
  printf '[ERROR] Do not run this script as root or with sudo.\n' >&2
  exit 1
}
[[ -f "$SNIPPET" ]] || {
  printf '[ERROR] Snippet not found: %s\n' "$SNIPPET" >&2
  exit 1
}

if [[ -f "$TARGET" ]] && grep -Fq "$MARKER" "$TARGET"; then
  printf '[INFO] Managed shell block already exists in %s; no changes made.\n' "$TARGET"
  exit 0
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  printf '[DRY RUN] Target: %s\n' "$TARGET"
  if [[ -e "$TARGET" ]]; then
    printf '[DRY RUN] Would create a timestamped backup.\n'
  fi
  printf '[DRY RUN] Would append:\n\n'
  cat "$SNIPPET"
  exit 0
fi

mkdir -p "$(dirname "$TARGET")"

if [[ -e "$TARGET" ]]; then
  backup="${TARGET}.backup.$(date '+%Y%m%d-%H%M%S')"
  cp -p "$TARGET" "$backup"
  printf '[INFO] Backed up %s to %s\n' "$TARGET" "$backup"
fi

needs_newline=0
if [[ -s "$TARGET" ]]; then
  needs_newline=1
fi

{
  if [[ "$needs_newline" -eq 1 ]]; then
    printf '\n'
  fi
  cat "$SNIPPET"
} >>"$TARGET"

printf '[INFO] Added the managed Homebrew/mise block to %s\n' "$TARGET"
printf '[INFO] Open a new terminal to load it.\n'
