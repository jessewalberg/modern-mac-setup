#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
umask 077

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
SNIPPET="$ROOT_DIR/snippets/zshrc"
TARGET="${ZDOTDIR:-$HOME}/.zshrc"
START_MARKER='# >>> modern-mac-setup >>>'
END_MARKER='# <<< modern-mac-setup <<<'
DRY_RUN=0
GENERATED=""
STAGED=""

usage() {
  cat <<'EOF'
Usage: ./scripts/configure-shell.sh [--dry-run]

Adds or updates one managed block in ~/.zshrc. Before changing an existing
regular file, the script creates a timestamped backup. A malformed managed
block or symlinked .zshrc is left untouched for manual review.
EOF
}

cleanup() {
  if [[ -n "$GENERATED" && -f "$GENERATED" ]]; then
    rm -f "$GENERATED"
  fi
  if [[ -n "$STAGED" && -f "$STAGED" ]]; then
    rm -f "$STAGED"
  fi
}
trap cleanup EXIT HUP INT TERM

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
if [[ "$EUID" -eq 0 && "${MODERN_MAC_TESTING:-0}" != '1' ]]; then
  printf '[ERROR] Do not run this script as root or with sudo.\n' >&2
  exit 1
fi
[[ -f "$SNIPPET" ]] || {
  printf '[ERROR] Snippet not found: %s\n' "$SNIPPET" >&2
  exit 1
}

snippet_start_count="$(grep -Fxc "$START_MARKER" "$SNIPPET" || true)"
snippet_end_count="$(grep -Fxc "$END_MARKER" "$SNIPPET" || true)"
if [[ "$snippet_start_count" -ne 1 || "$snippet_end_count" -ne 1 ]]; then
  printf '[ERROR] The managed snippet must contain exactly one start and end marker.\n' >&2
  exit 1
fi

if [[ -L "$TARGET" ]]; then
  printf '[ERROR] %s is a symlink. Update its dotfiles source manually instead of replacing the link.\n' "$TARGET" >&2
  exit 1
fi
if [[ -e "$TARGET" && ! -f "$TARGET" ]]; then
  printf '[ERROR] %s exists but is not a regular file.\n' "$TARGET" >&2
  exit 1
fi

start_count=0
end_count=0
if [[ -f "$TARGET" ]]; then
  start_count="$(grep -Fxc "$START_MARKER" "$TARGET" || true)"
  end_count="$(grep -Fxc "$END_MARKER" "$TARGET" || true)"
fi
if ! { [[ "$start_count" -eq 0 && "$end_count" -eq 0 ]] || [[ "$start_count" -eq 1 && "$end_count" -eq 1 ]]; }; then
  printf '[ERROR] %s contains a malformed or duplicated managed block; no changes were made.\n' "$TARGET" >&2
  exit 1
fi

GENERATED="$(mktemp "${TMPDIR:-/tmp}/modern-mac-zshrc-generated.XXXXXX")"
if [[ "$start_count" -eq 1 ]]; then
  awk -v start="$START_MARKER" -v end="$END_MARKER" -v snippet="$SNIPPET" '
    $0 == start {
      while ((getline line < snippet) > 0) print line
      close(snippet)
      in_block = 1
      next
    }
    in_block && $0 == end {
      in_block = 0
      next
    }
    !in_block { print }
    END { if (in_block) exit 2 }
  ' "$TARGET" >"$GENERATED" || {
    printf '[ERROR] Could not replace the managed shell block safely.\n' >&2
    exit 1
  }
  action='update'
else
  if [[ -s "$TARGET" ]]; then
    cat "$TARGET" >"$GENERATED"
    printf '\n' >>"$GENERATED"
  fi
  cat "$SNIPPET" >>"$GENERATED"
  action='add'
fi

if [[ -f "$TARGET" ]] && cmp -s "$TARGET" "$GENERATED"; then
  printf '[INFO] Managed shell block is already current in %s; no changes made.\n' "$TARGET"
  exit 0
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  printf '[DRY RUN] Would %s the managed block in %s.\n' "$action" "$TARGET"
  if [[ -f "$TARGET" ]]; then
    diff -u "$TARGET" "$GENERATED" || true
  else
    cat "$GENERATED"
  fi
  exit 0
fi

target_dir="$(dirname "$TARGET")"
mkdir -p "$target_dir"
STAGED="$(mktemp "${target_dir}/.modern-mac-zshrc.XXXXXX")"

if [[ -f "$TARGET" ]]; then
  backup="${TARGET}.backup.$(date '+%Y%m%d-%H%M%S').$$"
  cp -p "$TARGET" "$backup"
  cp -p "$TARGET" "$STAGED"
  printf '[INFO] Backed up %s to %s\n' "$TARGET" "$backup"
fi

cat "$GENERATED" >"$STAGED"
mv "$STAGED" "$TARGET"
STAGED=""

if [[ "$action" == 'add' ]]; then
  action_label='Added'
else
  action_label='Updated'
fi
printf '[INFO] %s the managed Homebrew/mise block in %s.\n' "$action_label" "$TARGET"
printf '[INFO] Open a new terminal to load it.\n'
