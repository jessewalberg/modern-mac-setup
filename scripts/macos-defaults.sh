#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
umask 077

APPLY=0
DRY_RUN=1

usage() {
  cat <<'EOF'
Usage: ./scripts/macos-defaults.sh [--apply]

With no arguments, prints the exact commands without changing the Mac.
--apply records previous values and applies four narrow preferences.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --apply)
      APPLY=1
      DRY_RUN=0
      ;;
    --dry-run)
      APPLY=0
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
  printf '[ERROR] This script supports macOS only.\n' >&2
  exit 1
}
[[ "$EUID" -ne 0 ]] || {
  printf '[ERROR] Do not run this script as root or with sudo.\n' >&2
  exit 1
}

print_command() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'
}

run() {
  print_command "$@"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    "$@"
  fi
}

snapshot_setting() {
  local domain="$1"
  local key="$2"
  local output="$3"
  local value

  {
    printf 'domain=%s\n' "$domain"
    printf 'key=%s\n' "$key"
    if value="$(defaults read "$domain" "$key" 2>/dev/null)"; then
      printf 'present=true\n'
      printf 'value=%s\n' "$value"
    else
      printf 'present=false\n'
    fi
  } >"$output"
}

screenshots_dir="$HOME/Pictures/Screenshots"

if [[ "$APPLY" -eq 1 ]]; then
  state_root="${XDG_STATE_HOME:-$HOME/.local/state}/modern-mac-setup/defaults"
  backup_dir="$state_root/$(date '+%Y%m%d-%H%M%S')"
  mkdir -p "$backup_dir"

  snapshot_setting NSGlobalDomain AppleShowAllExtensions "$backup_dir/NSGlobalDomain.AppleShowAllExtensions.txt"
  snapshot_setting com.apple.finder ShowPathbar "$backup_dir/com.apple.finder.ShowPathbar.txt"
  snapshot_setting com.apple.finder ShowStatusBar "$backup_dir/com.apple.finder.ShowStatusBar.txt"
  snapshot_setting com.apple.screencapture location "$backup_dir/com.apple.screencapture.location.txt"
  printf '[INFO] Previous values recorded in %s\n' "$backup_dir"
else
  printf '[INFO] Dry run only. Pass --apply after reviewing every command.\n'
fi

run mkdir -p "$screenshots_dir"
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
run defaults write com.apple.finder ShowPathbar -bool true
run defaults write com.apple.finder ShowStatusBar -bool true
run defaults write com.apple.screencapture location -string "$screenshots_dir"

if [[ "$DRY_RUN" -eq 0 ]]; then
  killall Finder >/dev/null 2>&1 || true
  killall SystemUIServer >/dev/null 2>&1 || true
  printf '[INFO] Preferences applied. Finder and SystemUIServer were refreshed.\n'
else
  print_command killall Finder
  print_command killall SystemUIServer
fi
