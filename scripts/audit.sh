#!/bin/bash

set -uo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck source=scripts/lib/platform.sh
source "$ROOT_DIR/scripts/lib/platform.sh"

MODE='auto'
DEEP=0
TEMP_FILE=""
ERRORS=0
WARNINGS=0
ARCH=""
EXPECTED_BREW_PREFIX=""
EXPECTED_BREW=""
SECONDARY_BREW_PREFIX=""
SECONDARY_BREW=""
BREW_BIN=""
APPLE_GIT=""

usage() {
  cat <<'EOF'
Usage: ./scripts/audit.sh [--preflight | --post-bootstrap] [--deep]

Modes:
  --preflight        Check whether the Mac is ready to bootstrap. Missing
                     Homebrew packages are informational.
  --post-bootstrap   Require the default Homebrew foundation and a usable PATH.
  no mode flag       Select post-bootstrap when native Homebrew exists;
                     otherwise select preflight.

--deep also runs Brewfile checks, brew doctor, mise doctor, and GitHub CLI
authentication checks. The audit is read-only. It exits nonzero for actionable
errors, while policy and hardening observations remain warnings.
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --preflight)
      [[ "$MODE" == 'auto' ]] || {
        printf '[ERROR] Choose only one audit mode.\n' >&2
        exit 1
      }
      MODE='preflight'
      ;;
    --post-bootstrap)
      [[ "$MODE" == 'auto' ]] || {
        printf '[ERROR] Choose only one audit mode.\n' >&2
        exit 1
      }
      MODE='post-bootstrap'
      ;;
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
  printf '[OK]    %s\n' "$*"
}

note() {
  printf '[INFO]  %s\n' "$*"
}

warn() {
  WARNINGS=$((WARNINGS + 1))
  printf '[WARN]  %s\n' "$*"
}

error() {
  ERRORS=$((ERRORS + 1))
  printf '[ERROR] %s\n' "$*"
}

first_line() {
  local value="$1"
  printf '%s\n' "${value%%$'\n'*}"
}

cleanup() {
  if [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]]; then
    rm -f "$TEMP_FILE"
  fi
}
trap cleanup EXIT HUP INT TERM

report_version() {
  local label="$1"
  local path="$2"
  shift 2

  if [[ ! -x "$path" ]]; then
    error "$label is not executable at $path."
    return 1
  fi

  local output
  if output="$("$path" "$@" 2>&1)"; then
    ok "$label: $(first_line "$output") ($path)"
    return 0
  fi

  error "$label exists at $path but failed: $(first_line "$output")"
  return 1
}

report_named_command() {
  local command_name="$1"
  local label="$2"
  local required="$3"
  local path output

  if ! path="$(command -v "$command_name" 2>/dev/null)"; then
    if [[ "$required" == '1' ]]; then
      error "$label ($command_name) is not available in the current shell."
    else
      note "$label ($command_name) is not installed; this is expected before bootstrap or when the layer is optional."
    fi
    return 1
  fi

  if output="$("$path" --version 2>&1)"; then
    ok "$label: $(first_line "$output") ($path)"
    return 0
  fi

  error "$label exists at $path but failed: $(first_line "$output")"
  return 1
}

modern_mac_validate_test_root || exit 1
if [[ "$(uname -s)" != 'Darwin' ]]; then
  printf '[ERROR] This audit supports macOS only.\n' >&2
  exit 1
fi
if [[ "$EUID" -eq 0 && "${MODERN_MAC_TESTING:-0}" != '1' ]]; then
  printf '[ERROR] Run the audit as the logged-in user, not root or sudo.\n' >&2
  exit 1
fi

ARCH="$(uname -m)"
if ! EXPECTED_BREW_PREFIX="$(modern_mac_expected_brew_prefix_for_arch "$ARCH")"; then
  printf '[ERROR] Unsupported Mac architecture: %s\n' "$ARCH" >&2
  exit 1
fi
EXPECTED_BREW="$(modern_mac_expected_brew_bin_for_arch "$ARCH")"
SECONDARY_BREW_PREFIX="$(modern_mac_secondary_brew_prefix_for_arch "$ARCH")"
SECONDARY_BREW="$(modern_mac_secondary_brew_bin_for_arch "$ARCH")"

if [[ "$MODE" == 'auto' ]]; then
  if [[ -x "$EXPECTED_BREW" ]]; then
    MODE='post-bootstrap'
  else
    MODE='preflight'
  fi
fi

printf 'Modern Mac Setup audit\n'
printf '======================\n\n'
note "Mode: $MODE"

version="$(sw_vers -productVersion 2>/dev/null || printf 'unknown')"
build="$(sw_vers -buildVersion 2>/dev/null || printf 'unknown')"
note "macOS $version (build $build), architecture $ARCH"

major="${version%%.*}"
case "$major" in
  '' | *[!0-9]*) error "Could not parse the macOS version: $version" ;;
  *)
    if [[ "$major" -lt 14 ]]; then
      error "macOS $version is outside the supported target of macOS 14 or newer."
    fi
    ;;
esac

if modern_mac_is_translated; then
  error 'Current terminal is translated by Rosetta; use a native terminal for Homebrew.'
else
  ok 'Current terminal is running natively.'
fi

filevault="$(fdesetup status 2>/dev/null || true)"
if printf '%s' "$filevault" | grep -qi 'FileVault is On'; then
  ok "$filevault"
else
  warn "FileVault status: ${filevault:-unknown}"
fi

firewall_bin="$(modern_mac_firewall_bin)"
if [[ -x "$firewall_bin" ]]; then
  firewall="$("$firewall_bin" --getglobalstate 2>/dev/null || true)"
  if printf '%s' "$firewall" | grep -qi 'enabled'; then
    ok "$firewall"
  else
    warn "Firewall status: ${firewall:-unknown}"
  fi
else
  warn "macOS firewall status utility was not found at $firewall_bin."
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

if ! TEMP_FILE="$(mktemp "${TMPDIR:-/tmp}/modern-mac-audit.XXXXXX")"; then
  printf '[ERROR] Could not create a temporary audit file.\n' >&2
  exit 1
fi
if tmutil destinationinfo >"$TEMP_FILE" 2>&1; then
  destination="$(awk -F ': ' '/^Name/{print $2; exit}' "$TEMP_FILE")"
  ok "Time Machine destination configured${destination:+: $destination}"
else
  warn 'No Time Machine destination was detected. Confirm another tested backup exists.'
fi

printf '\nDeveloper tools\n---------------\n'
if developer_dir="$(xcode-select -p 2>/dev/null)"; then
  ok "Active Apple developer directory: $developer_dir"

  if APPLE_GIT="$(xcrun --find git 2>/dev/null)"; then
    report_version 'Apple Git' "$APPLE_GIT" --version || true
  else
    error 'The active Apple developer tools cannot locate Git.'
  fi

  if apple_clang="$(xcrun --find clang 2>/dev/null)"; then
    report_version 'Apple clang' "$apple_clang" --version || true
  else
    error 'The active Apple developer tools cannot locate clang.'
  fi
else
  error 'Apple Command Line Tools or Xcode are not installed and selected.'
fi

printf '\nHomebrew architecture\n---------------------\n'
if [[ -x "$EXPECTED_BREW" ]]; then
  if brew_prefix="$("$EXPECTED_BREW" --prefix 2>/dev/null)"; then
    if [[ "$brew_prefix" == "$EXPECTED_BREW_PREFIX" ]]; then
      BREW_BIN="$EXPECTED_BREW"
      report_version 'Homebrew' "$BREW_BIN" --version || true
      ok "Homebrew prefix matches $ARCH: $EXPECTED_BREW_PREFIX"
    else
      error "Homebrew at $EXPECTED_BREW reports $brew_prefix; expected $EXPECTED_BREW_PREFIX."
    fi
  else
    error "Homebrew exists at $EXPECTED_BREW but cannot report its prefix."
  fi
else
  if [[ "$MODE" == 'post-bootstrap' ]]; then
    error "Native Homebrew is missing at $EXPECTED_BREW."
  else
    note "Native Homebrew is not installed yet; the bootstrap will use $EXPECTED_BREW_PREFIX."
  fi
fi

if [[ -x "$SECONDARY_BREW" ]]; then
  secondary_prefix="$("$SECONDARY_BREW" --prefix 2>/dev/null || true)"
  if [[ "$secondary_prefix" == "$SECONDARY_BREW_PREFIX" ]]; then
    if [[ -z "$BREW_BIN" ]]; then
      error "Only the other-architecture Homebrew was found at $SECONDARY_BREW_PREFIX."
    else
      warn "A secondary Homebrew installation also exists at $SECONDARY_BREW_PREFIX. Keep it only for a documented legacy requirement."
    fi
  fi
fi

if path_brew="$(command -v brew 2>/dev/null)"; then
  path_prefix="$("$path_brew" --prefix 2>/dev/null || true)"
  if [[ "$path_prefix" == "$EXPECTED_BREW_PREFIX" ]]; then
    ok "brew in PATH resolves to the native prefix: $path_brew"
  else
    error "brew in PATH resolves to $path_brew with prefix ${path_prefix:-unknown}; expected $EXPECTED_BREW_PREFIX."
  fi
elif [[ "$MODE" == 'post-bootstrap' ]]; then
  error 'Homebrew exists or is expected, but brew is not available in the current shell PATH.'
else
  note 'brew is not in PATH before bootstrap.'
fi

printf '\nCommand ownership\n-----------------\n'
if active_git="$(command -v git 2>/dev/null)"; then
  if git_output="$("$active_git" --version 2>&1)"; then
    if [[ -n "$APPLE_GIT" && "$active_git" == "$APPLE_GIT" ]]; then
      ok "Active Git is Apple Git: $(first_line "$git_output") ($active_git)"
    elif [[ "$active_git" == "$(modern_mac_root_path "$EXPECTED_BREW_PREFIX")"/* ]]; then
      ok "Active Git is the optional Homebrew Git: $(first_line "$git_output") ($active_git)"
    else
      warn "Active Git comes from a custom path: $(first_line "$git_output") ($active_git)"
    fi
  else
    error "Active Git exists at $active_git but failed: $(first_line "$git_output")"
  fi
else
  error 'git is not available in the current shell.'
fi

required=0
if [[ "$MODE" == 'post-bootstrap' ]]; then
  required=1
fi
report_named_command gh 'GitHub CLI' "$required" || true
report_named_command mise 'mise' "$required" || true
report_named_command uv 'uv' "$required" || true

if [[ "$DEEP" -eq 1 ]]; then
  printf '\nDeep checks\n-----------\n'

  if [[ -n "$BREW_BIN" ]]; then
    if env HOMEBREW_NO_AUTO_UPDATE=1 "$BREW_BIN" bundle check --file="$ROOT_DIR/Brewfile" --no-upgrade >"$TEMP_FILE" 2>&1; then
      ok 'Minimal Brewfile is satisfied.'
    elif [[ "$MODE" == 'post-bootstrap' ]]; then
      error 'Minimal Brewfile is not satisfied.'
      sed 's/^/        /' "$TEMP_FILE"
    else
      note 'Minimal Brewfile is not satisfied before bootstrap.'
    fi

    if env HOMEBREW_NO_AUTO_UPDATE=1 "$BREW_BIN" bundle check --file="$ROOT_DIR/Brewfile.git" --no-upgrade >/dev/null 2>&1; then
      ok 'Optional Homebrew Git layer is installed.'
    else
      note 'Optional Homebrew Git layer is not installed.'
    fi

    if env HOMEBREW_NO_AUTO_UPDATE=1 "$BREW_BIN" bundle check --file="$ROOT_DIR/Brewfile.cli" --no-upgrade >/dev/null 2>&1; then
      ok 'Optional CLI Brewfile is satisfied.'
    else
      note 'Optional CLI Brewfile is not fully installed.'
    fi

    if env HOMEBREW_NO_AUTO_UPDATE=1 "$BREW_BIN" doctor >"$TEMP_FILE" 2>&1; then
      ok 'brew doctor reported no problems.'
    else
      warn 'brew doctor reported findings:'
      sed 's/^/        /' "$TEMP_FILE"
    fi
  else
    note 'Homebrew deep checks were skipped because native Homebrew is unavailable.'
  fi

  if command -v gh >/dev/null 2>&1; then
    if gh auth status --hostname github.com >"$TEMP_FILE" 2>&1; then
      ok 'GitHub CLI is authenticated to github.com.'
    else
      warn 'GitHub CLI is not authenticated to github.com.'
      sed 's/^/        /' "$TEMP_FILE"
    fi
  fi

  if command -v mise >/dev/null 2>&1; then
    if mise doctor >"$TEMP_FILE" 2>&1; then
      ok 'mise doctor reported no problems.'
    else
      warn 'mise doctor reported findings:'
      sed 's/^/        /' "$TEMP_FILE"
    fi
  fi
fi

printf '\nSummary: %d error(s), %d warning(s).\n' "$ERRORS" "$WARNINGS"
printf 'Warnings require context; errors block the selected setup phase.\n'

if [[ "$ERRORS" -gt 0 ]]; then
  exit 1
fi
