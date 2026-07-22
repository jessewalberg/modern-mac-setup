#!/bin/bash
#
# Optional, human-readable macOS preference helper.
#
# This script intentionally changes exactly four visible settings:
#
# Finder visibility
#   1. Show all filename extensions.
#   2. Show the path bar.
#   3. Show the status bar.
#
# Screenshot storage
#   4. Save future files from the built-in Screenshot tools in
#      ~/Pictures/Screenshots.
#
# Applying the plan also creates that screenshot directory when needed and
# restarts Finder and SystemUIServer so the new values are noticed. Existing
# screenshots and recordings are not moved.
#
# Run with no arguments to read the plan and print the exact commands. The
# script is deliberately separate from bootstrap.sh because these are personal
# interface choices, not developer-tool requirements.

set -euo pipefail
IFS=$'\n\t'
umask 077

APPLY=0
DRY_RUN=1
screenshots_dir="$HOME/Pictures/Screenshots"

usage() {
  cat <<'EOF'
Usage: ./scripts/macos-defaults.sh [--apply]

No arguments
  Explain all four choices and print the exact commands without changing the Mac.

--apply
  Record the previous raw values, then apply all four choices.

The choices are:

  Finder visibility
    1. Show all filename extensions.
       Manual path: Finder > Settings > Advanced >
                    Show all filename extensions

    2. Show the path bar at the bottom of Finder windows.
       Manual path: Finder > View > Show Path Bar

    3. Show the status bar with item count and available disk space.
       Manual path: Finder > View > Show Status Bar

  Screenshot storage
    4. Save future files from the built-in Screenshot tools in
       ~/Pictures/Screenshots.
       Manual path: Shift-Command-5 > Options > Save to > Other Location

Applying also creates the screenshot directory when needed and briefly restarts
Finder and SystemUIServer. Existing screenshots and recordings are not moved.
Previous raw values are recorded for reference, but this script does not provide
an automatic restore command.
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
  printf ' +'
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

print_plan() {
  local mode='PREVIEW ONLY'
  if [[ "$APPLY" -eq 1 ]]; then
    mode='APPLY'
  fi

  cat <<EOF
macOS preference plan — ${mode}

Finder visibility

1. Show all filename extensions
   What changes:
     Finder displays extensions such as .md, .json, .sh, and .png.

   Why consider it:
     File types are visible instead of being inferred from icons or apps.

   Manual equivalent:
     Finder > Settings > Advanced > Show all filename extensions

2. Show the Finder path bar
   What changes:
     Finder displays the current folder hierarchy at the bottom of each window.

   Why consider it:
     The location of a file is visible, and parent folders are easier to open.

   Manual equivalent:
     Finder > View > Show Path Bar

3. Show the Finder status bar
   What changes:
     Finder displays the item count and available disk space.

   Why consider it:
     Folder and disk context stays visible while browsing files.

   Manual equivalent:
     Finder > View > Show Status Bar

Screenshot storage

4. Save future Screenshot files in:
     ${screenshots_dir}

   What changes:
     Future screenshots and screen recordings made with the built-in Screenshot
     tools use this folder instead of the current save location.

   What does not change:
     Existing screenshots and recordings are not moved.

   Manual equivalent:
     Shift-Command-5 > Options > Save to > Other Location

Additional effects when applied

- Creates ${screenshots_dir} when it does not exist.
- Records the previous raw values under:
    ~/.local/state/modern-mac-setup/defaults/TIMESTAMP/
- Restarts Finder and SystemUIServer. Finder windows and parts of the menu bar
  may briefly disappear and relaunch.
- Does not install software, grant privacy permissions, or change security
  controls.
- Does not provide automatic restore. Use the manual paths above to change a
  choice back.

Exact commands
EOF
}

print_plan

if [[ "$APPLY" -eq 1 ]]; then
  state_root="${XDG_STATE_HOME:-$HOME/.local/state}/modern-mac-setup/defaults"
  backup_dir="$state_root/$(date '+%Y%m%d-%H%M%S')"
  mkdir -p "$backup_dir"

  snapshot_setting NSGlobalDomain AppleShowAllExtensions "$backup_dir/NSGlobalDomain.AppleShowAllExtensions.txt"
  snapshot_setting com.apple.finder ShowPathbar "$backup_dir/com.apple.finder.ShowPathbar.txt"
  snapshot_setting com.apple.finder ShowStatusBar "$backup_dir/com.apple.finder.ShowStatusBar.txt"
  snapshot_setting com.apple.screencapture location "$backup_dir/com.apple.screencapture.location.txt"
  printf '[INFO] Previous raw values recorded in %s\n' "$backup_dir"
  printf '[INFO] These records are for reference; they are not an automatic restore bundle.\n'
else
  printf '[INFO] Dry run only. Pass --apply after reviewing every choice and command.\n'
fi

# Screenshot storage: create the selected destination before writing the setting.
run mkdir -p "$screenshots_dir"

# Finder > Settings > Advanced > Show all filename extensions.
run defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder > View > Show Path Bar.
run defaults write com.apple.finder ShowPathbar -bool true

# Finder > View > Show Status Bar.
run defaults write com.apple.finder ShowStatusBar -bool true

# Shift-Command-5 > Options > Save to > Other Location.
run defaults write com.apple.screencapture location -string "$screenshots_dir"

if [[ "$DRY_RUN" -eq 0 ]]; then
  killall Finder >/dev/null 2>&1 || true
  killall SystemUIServer >/dev/null 2>&1 || true
  printf '[INFO] Finder and SystemUIServer were restarted so the changes become visible.\n'
  printf '[INFO] Existing screenshots and recordings were not moved.\n'
else
  printf '\nInterface refresh commands that would run after applying:\n'
  print_command killall Finder
  print_command killall SystemUIServer
fi
