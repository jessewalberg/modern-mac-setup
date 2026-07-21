#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
umask 077

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
# shellcheck source=scripts/lib/platform.sh
source "$ROOT_DIR/scripts/lib/platform.sh"

INSTALL_HOMEBREW=0
WITH_CLI=0
WITH_HOMEBREW_GIT=0
APPS_FILE=""
CONFIGURE_SHELL=0
APPLY_DEFAULTS=0
UPDATE_HOMEBREW=1
DRY_RUN=0
HOMEBREW_INSTALLER=""
HOMEBREW_INSTALLER_REF="99e13e96cbbdc1ac1ac09c0a40b450bf219ef3aa"
HOMEBREW_INSTALLER_BLOB_SHA="c9778f3ef27abce4b907d17b8a736cc9a5861073"
ARCH=""
EXPECTED_BREW_PREFIX=""
EXPECTED_BREW=""
SECONDARY_BREW_PREFIX=""
SECONDARY_BREW=""
BREW_BIN=""
BOOTSTRAP_GIT=""

usage() {
  cat <<'EOF'
Usage: ./scripts/bootstrap.sh [options]

Options:
  --install-homebrew      Permit downloading and running Homebrew's installer.
  --with-homebrew-git     Install the optional Brewfile.git layer.
  --with-cli              Install the optional Brewfile.cli layer.
  --apps FILE             Install an explicitly reviewed apps Brewfile.
  --configure-shell       Add or update the managed Homebrew/mise zsh block.
  --apply-defaults        Apply the narrow settings in macos-defaults.sh.
  --no-update             Skip the explicit `brew update` step.
  --dry-run               Print planned commands without changing the machine.
  -h, --help              Show this help.

The default Brewfile installs GitHub CLI, mise, and uv. Apple's Command Line
Tools provide the bootstrap/default Git; Homebrew Git is opt-in.
EOF
}

info() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

die() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

first_line() {
  local value="$1"
  printf '%s\n' "${value%%$'\n'*}"
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

cleanup() {
  if [[ -n "$HOMEBREW_INSTALLER" && -f "$HOMEBREW_INSTALLER" ]]; then
    rm -f "$HOMEBREW_INSTALLER"
  fi
}

trap cleanup EXIT HUP INT TERM

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --install-homebrew)
      INSTALL_HOMEBREW=1
      ;;
    --with-homebrew-git)
      WITH_HOMEBREW_GIT=1
      ;;
    --with-cli)
      WITH_CLI=1
      ;;
    --apps)
      [[ "$#" -ge 2 ]] || die '--apps requires a file path'
      APPS_FILE="$2"
      shift
      ;;
    --configure-shell)
      CONFIGURE_SHELL=1
      ;;
    --apply-defaults)
      APPLY_DEFAULTS=1
      ;;
    --no-update)
      UPDATE_HOMEBREW=0
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
  shift
done

check_platform() {
  modern_mac_validate_test_root || exit 1
  [[ "$(uname -s)" == 'Darwin' ]] || die 'This bootstrap supports macOS only.'

  if [[ "$EUID" -eq 0 && "${MODERN_MAC_TESTING:-0}" != '1' ]]; then
    die 'Do not run this script as root or with sudo.'
  fi

  if modern_mac_is_translated; then
    die 'This terminal is running under Rosetta. Relaunch the terminal natively before using Homebrew.'
  fi

  local version major
  version="$(sw_vers -productVersion 2>/dev/null || true)"
  major="${version%%.*}"
  case "$major" in
    '' | *[!0-9]*) die "Could not determine the macOS version: ${version:-unknown}" ;;
    *)
      if [[ "$major" -lt 14 ]]; then
        die "macOS $version is outside this guide's supported target. Update to macOS 14 or newer first."
      fi
      ;;
  esac

  ARCH="$(uname -m)"
  EXPECTED_BREW_PREFIX="$(modern_mac_expected_brew_prefix_for_arch "$ARCH")" ||
    die "Unsupported Mac architecture: $ARCH"
  SECONDARY_BREW_PREFIX="$(modern_mac_secondary_brew_prefix_for_arch "$ARCH")"
  EXPECTED_BREW="$(modern_mac_expected_brew_bin_for_arch "$ARCH")"
  SECONDARY_BREW="$(modern_mac_secondary_brew_bin_for_arch "$ARCH")"

  info "macOS $version on $ARCH; supported Homebrew prefix: $EXPECTED_BREW_PREFIX"
}

request_command_line_tools() {
  warn 'Apple Command Line Tools are not installed or selected.'
  if [[ "$DRY_RUN" -eq 1 ]]; then
    print_command xcode-select --install
  else
    local request_output
    if request_output="$(xcode-select --install 2>&1)"; then
      info 'Requested the Apple Command Line Tools installer.'
    elif [[ -n "$request_output" ]]; then
      warn "xcode-select --install reported: $(first_line "$request_output")"
    fi
  fi

  cat >&2 <<'EOF'
Complete Apple's installer, open a new terminal, and rerun this command. The
bootstrap stops here because Apple Git, clang, and Homebrew must not be used
against a missing or half-finished developer-tools installation.
EOF
  exit 2
}

ensure_command_line_tools() {
  local developer_dir git_output clang_path clang_output

  if ! developer_dir="$(xcode-select -p 2>/dev/null)"; then
    request_command_line_tools
  fi

  if ! BOOTSTRAP_GIT="$(xcrun --find git 2>/dev/null)" || [[ ! -x "$BOOTSTRAP_GIT" ]]; then
    die 'The active Apple developer tools cannot locate Git. Reinstall or reselect the Command Line Tools.'
  fi
  if ! git_output="$("$BOOTSTRAP_GIT" --version 2>&1)"; then
    die "Apple Git exists at $BOOTSTRAP_GIT but could not run: $(first_line "$git_output")"
  fi

  if ! clang_path="$(xcrun --find clang 2>/dev/null)" || [[ ! -x "$clang_path" ]]; then
    die 'The active Apple developer tools cannot locate clang. Reinstall or reselect the Command Line Tools.'
  fi
  if ! clang_output="$("$clang_path" --version 2>&1)"; then
    die "Apple clang exists at $clang_path but could not run: $(first_line "$clang_output")"
  fi

  info "Apple developer tools: $developer_dir"
  info "Bootstrap Git: $(first_line "$git_output") at $BOOTSTRAP_GIT"
  info "Compiler: $(first_line "$clang_output") at $clang_path"
}

brew_prefix() {
  "$1" --prefix 2>/dev/null
}

inspect_homebrew_state() {
  BREW_BIN=""

  local expected_prefix path_brew path_prefix secondary_prefix
  if [[ -x "$EXPECTED_BREW" ]]; then
    if ! expected_prefix="$(brew_prefix "$EXPECTED_BREW")"; then
      die "Homebrew exists at $EXPECTED_BREW but cannot report its prefix."
    fi
    if [[ "$expected_prefix" != "$EXPECTED_BREW_PREFIX" ]]; then
      die "Homebrew at $EXPECTED_BREW reports unsupported prefix $expected_prefix; expected $EXPECTED_BREW_PREFIX."
    fi
    BREW_BIN="$EXPECTED_BREW"
  fi

  if [[ -x "$SECONDARY_BREW" ]]; then
    if secondary_prefix="$(brew_prefix "$SECONDARY_BREW")"; then
      if [[ "$secondary_prefix" == "$SECONDARY_BREW_PREFIX" ]]; then
        if [[ -z "$BREW_BIN" ]]; then
          die "Found Homebrew only at the other architecture prefix $SECONDARY_BREW_PREFIX. Review docs/migration.md before installing a second Homebrew."
        fi
        warn "A secondary Homebrew installation exists at $SECONDARY_BREW_PREFIX. This bootstrap will use only $EXPECTED_BREW_PREFIX."
      fi
    elif [[ -z "$BREW_BIN" ]]; then
      die "An unusable brew executable exists at the other architecture path: $SECONDARY_BREW"
    fi
  fi

  if path_brew="$(command -v brew 2>/dev/null)"; then
    if ! path_prefix="$(brew_prefix "$path_brew")"; then
      die "brew resolves to $path_brew but cannot report its prefix."
    fi
    if [[ "$path_prefix" != "$EXPECTED_BREW_PREFIX" ]]; then
      die "brew in PATH resolves to $path_brew with prefix $path_prefix; this $ARCH process requires $EXPECTED_BREW_PREFIX. Fix the shell PATH before continuing."
    fi
    if [[ -z "$BREW_BIN" ]]; then
      die "brew in PATH reports $EXPECTED_BREW_PREFIX, but the supported executable is missing at $EXPECTED_BREW."
    fi
  fi
}

install_homebrew() {
  inspect_homebrew_state
  if [[ -n "$BREW_BIN" ]]; then
    info "Homebrew already exists at $BREW_BIN"
    return
  fi

  if [[ "$INSTALL_HOMEBREW" -ne 1 ]]; then
    die 'Homebrew is missing. Review this script, then rerun with --install-homebrew.'
  fi

  local installer_url
  installer_url="https://raw.githubusercontent.com/Homebrew/install/${HOMEBREW_INSTALLER_REF}/install.sh"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "Homebrew installer commit: $HOMEBREW_INSTALLER_REF"
    info "Expected installer Git blob: $HOMEBREW_INSTALLER_BLOB_SHA"
    print_command /usr/bin/curl -fsSL --proto '=https' --tlsv1.2 "$installer_url" -o '/tmp/homebrew-install.sh'
    print_command "$BOOTSTRAP_GIT" hash-object '/tmp/homebrew-install.sh'
    print_command /bin/bash '/tmp/homebrew-install.sh'
    BREW_BIN="$EXPECTED_BREW"
    return
  fi

  HOMEBREW_INSTALLER="$(mktemp "${TMPDIR:-/tmp}/modern-mac-homebrew.XXXXXX")"
  info "Downloading Homebrew's installer from reviewed commit $HOMEBREW_INSTALLER_REF."
  /usr/bin/curl -fsSL --proto '=https' --tlsv1.2 "$installer_url" -o "$HOMEBREW_INSTALLER"

  local actual_blob_sha checksum
  actual_blob_sha="$("$BOOTSTRAP_GIT" hash-object "$HOMEBREW_INSTALLER")"
  if [[ "$actual_blob_sha" != "$HOMEBREW_INSTALLER_BLOB_SHA" ]]; then
    die "Downloaded installer Git blob $actual_blob_sha does not match reviewed blob $HOMEBREW_INSTALLER_BLOB_SHA."
  fi

  checksum="$(/usr/bin/shasum -a 256 "$HOMEBREW_INSTALLER" | /usr/bin/awk '{print $1}')"
  info "Verified installer Git blob: $actual_blob_sha"
  info "Downloaded installer SHA-256: $checksum"
  run /bin/bash "$HOMEBREW_INSTALLER"

  inspect_homebrew_state
  [[ -n "$BREW_BIN" ]] || die "Homebrew installation finished, but $EXPECTED_BREW was not found."
}

load_homebrew_environment() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    [[ -n "$BREW_BIN" ]] || BREW_BIN="$EXPECTED_BREW"
    print_command "$BREW_BIN" shellenv
    return
  fi

  [[ -n "$BREW_BIN" ]] || die 'Internal error: Homebrew was not selected.'

  local shellenv path_brew path_prefix
  if ! shellenv="$("$BREW_BIN" shellenv 2>&1)"; then
    die "Homebrew could not produce shell environment settings: $(first_line "$shellenv")"
  fi
  eval "$shellenv"

  if ! path_brew="$(command -v brew 2>/dev/null)"; then
    die 'Homebrew shell environment loaded, but brew is still unavailable in PATH.'
  fi
  path_prefix="$(brew_prefix "$path_brew")" || die "brew in PATH cannot report its prefix after shell initialization."
  if [[ "$path_prefix" != "$EXPECTED_BREW_PREFIX" ]]; then
    die "Homebrew shell initialization selected $path_prefix; expected $EXPECTED_BREW_PREFIX."
  fi

  local brew_version
  if ! brew_version="$("$BREW_BIN" --version 2>&1)"; then
    die "Homebrew exists at $BREW_BIN but --version failed: $(first_line "$brew_version")"
  fi
  info "Homebrew: $(first_line "$brew_version") at $EXPECTED_BREW_PREFIX"
}

install_bundle() {
  local file="$1"
  local label="$2"

  [[ -f "$file" ]] || die "$label file not found: $file"
  info "Installing $label from $file"
  run env HOMEBREW_NO_AUTO_UPDATE=1 "$BREW_BIN" bundle install --file="$file" --no-upgrade

  if [[ "$DRY_RUN" -eq 0 ]]; then
    env HOMEBREW_NO_AUTO_UPDATE=1 "$BREW_BIN" bundle check --file="$file" --no-upgrade
  fi
}

check_platform
ensure_command_line_tools
install_homebrew
load_homebrew_environment

if [[ "$UPDATE_HOMEBREW" -eq 1 ]]; then
  info 'Refreshing Homebrew metadata without upgrading installed formulae.'
  run "$BREW_BIN" update
else
  warn 'Skipping brew update by explicit request.'
fi

install_bundle "$ROOT_DIR/Brewfile" 'minimal foundation'

if [[ "$WITH_HOMEBREW_GIT" -eq 1 ]]; then
  install_bundle "$ROOT_DIR/Brewfile.git" 'optional Homebrew Git'
fi

if [[ "$WITH_CLI" -eq 1 ]]; then
  install_bundle "$ROOT_DIR/Brewfile.cli" 'optional CLI tools'
fi

if [[ -n "$APPS_FILE" ]]; then
  [[ -f "$APPS_FILE" ]] || die "Apps Brewfile not found: $APPS_FILE"
  install_bundle "$APPS_FILE" 'reviewed applications'
fi

if [[ "$CONFIGURE_SHELL" -eq 1 ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run "$ROOT_DIR/scripts/configure-shell.sh" --dry-run
  else
    run "$ROOT_DIR/scripts/configure-shell.sh"
  fi
else
  warn 'Shell configuration was not changed. Confirm brew is available in a new terminal or run ./scripts/configure-shell.sh.'
fi

if [[ "$APPLY_DEFAULTS" -eq 1 ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run "$ROOT_DIR/scripts/macos-defaults.sh"
  else
    run "$ROOT_DIR/scripts/macos-defaults.sh" --apply
  fi
fi

cat <<EOF

Bootstrap complete.

Ownership summary:
  - Apple Command Line Tools own the bootstrap/default Git: $BOOTSTRAP_GIT
  - Homebrew owns GitHub CLI, mise, uv, and selected optional packages.
  - Homebrew Git is installed only when --with-homebrew-git is selected.

Next deliberate steps:
  1. Open a new terminal if the managed shell block was installed or updated.
  2. Run ./scripts/audit.sh --post-bootstrap --deep.
  3. Set a Git name and an appropriate public or private commit email.
  4. Run gh auth login and choose HTTPS or SSH deliberately.
  5. Pin language versions inside each project rather than globally here.
EOF
