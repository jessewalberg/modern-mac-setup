#!/bin/bash

set -u
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
DEEP=0
TEMP_FILE=""

usage() {
  cat <<'EOF'
Usage: ./scripts/audit.sh [--deep]

Runs read-only checks. The deep audit also runs Homebrew bundle checks,
`brew doctor`, `mise doctor`, and GitHub CLI authentication checks.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --deep)
      DEEP=1
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

ok() {
  printf '[OK]   %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*"
}

note() {
  printf '[INFO] %s\n' "$*"
}

cleanup() {
  if [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]]; then
    rm -f "$TEMP_FILE"
  fi
}
trap cleanup EXIT HUP INT TERM

if [[ "$(uname -s)" != 'Darwin' ]]; then
  printf '[ERROR] This audit supports macOS only.\n' >&2
  exit 1
fi

printf 'Modern Mac Setup audit\n'
printf '======================\n\n'

version="$(sw_vers -productVersion 2>/dev/null || printf 'unknown')"
build="$(sw_vers -buildVersion 2>/dev/null || printf 'unknown')"
note "macOS $version (build $build), architecture $(uname -m)"

translated="$(sysctl -n sysctl.proc_translated 2>/dev/null || true)"
if [[ "$translated" == '1' ]]; then
  warn 'Current terminal is translated by Rosetta; use a native terminal for Homebrew.'
else
  ok 'Current terminal is running natively.'
fi

filevault="$(fdesetup status 2>/dev/null || true)"
if printf '%s' "$filevault" | grep -qi 'FileVault is On'; then
  ok "$filevault"
else
  warn "FileVault status: ${filevault:-unknown}"
fi

firewall_bin='/usr/libexec/ApplicationFirewall/socketfilterfw'
if [[ -x "$firewall_bin" ]]; then
  firewall="$($firewall_bin --getglobalstate 2>/dev/null || true)"
  if printf '%s' "$firewall" | grep -qi 'enabled'; then
    ok "$firewall"
  else
    warn "Firewall status: ${firewall:-unknown}"
  fi
else
  warn 'macOS firewall status utility was not found.'
fi

gatekeeper="$(spctl --status 2>/dev/null || true)"
if printf '%s' "$gatekeeper" | grep -qi 'assessments enabled'; then
  ok "Gatekeeper: $gatekeeper"
else
  warn "Gatekeeper: ${gatekeeper:-unknown}"
fi

sip="$(csrutil status 2>/dev/null || true)"
if printf '%s' "$sip" | grep -qi 'enabled'; then
  ok "$sip"
else
  warn "System Integrity Protection: ${sip:-unknown}"
fi

TEMP_FILE="$(mktemp "${TMPDIR:-/tmp}/modern-mac-audit.XXXXXX")"
if tmutil destinationinfo >"$TEMP_FILE" 2>&1; then
  destination="$(awk -F ': ' '/^Name/{print $2; exit}' "$TEMP_FILE")"
  ok "Time Machine destination configured${destination:+: $destination}"
else
  warn 'No Time Machine destination was detected. Confirm another tested backup exists.'
fi

if clt_path="$(xcode-select -p 2>/dev/null)"; then
  ok "Apple Command Line Tools: $clt_path"
else
  warn 'Apple Command Line Tools are not installed or selected.'
fi

BREW_BIN=''
if command -v brew >/dev/null 2>&1; then
  BREW_BIN="$(command -v brew)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  BREW_BIN='/opt/homebrew/bin/brew'
elif [[ -x /usr/local/bin/brew ]]; then
  BREW_BIN='/usr/local/bin/brew'
fi

if [[ -n "$BREW_BIN" ]]; then
  eval "$("$BREW_BIN" shellenv)"
  ok "Homebrew $(brew --version | head -n 1) at $(brew --prefix)"
else
  warn 'Homebrew was not detected in PATH or either supported macOS prefix.'
fi

for command_name in git gh mise uv; do
  if command -v "$command_name" >/dev/null 2>&1; then
    version_line="$($command_name --version 2>&1 | head -n 1)"
    ok "$version_line"
  else
    warn "$command_name is not available in the current shell."
  fi
done

if [[ "$DEEP" -eq 1 ]]; then
  printf '\nDeep checks\n-----------\n'

  if [[ -n "$BREW_BIN" ]]; then
    if env HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="$ROOT_DIR/Brewfile" --no-upgrade >/dev/null 2>&1; then
      ok 'Minimal Brewfile is satisfied.'
    else
      warn 'Minimal Brewfile has missing or outdated declarations.'
      env HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="$ROOT_DIR/Brewfile" --no-upgrade --verbose || true
    fi

    if env HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="$ROOT_DIR/Brewfile.cli" --no-upgrade >/dev/null 2>&1; then
      ok 'Optional CLI Brewfile is satisfied.'
    else
      note 'Optional CLI Brewfile is not fully installed; this is acceptable when it was not selected.'
    fi

    if env HOMEBREW_NO_AUTO_UPDATE=1 brew doctor >"$TEMP_FILE" 2>&1; then
      ok 'brew doctor reported no problems.'
    else
      warn 'brew doctor reported findings:'
      sed 's/^/       /' "$TEMP_FILE"
    fi
  fi

  if command -v gh >/dev/null 2>&1; then
    if gh auth status --hostname github.com >"$TEMP_FILE" 2>&1; then
      ok 'GitHub CLI is authenticated to github.com.'
    else
      warn 'GitHub CLI is not authenticated to github.com.'
      sed 's/^/       /' "$TEMP_FILE"
    fi
  fi

  if command -v mise >/dev/null 2>&1; then
    if mise doctor >"$TEMP_FILE" 2>&1; then
      ok 'mise doctor reported no problems.'
    else
      warn 'mise doctor reported findings:'
      sed 's/^/       /' "$TEMP_FILE"
    fi
  fi
fi

printf '\nReview warnings in context. This script is an inventory, not a security scanner.\n'
