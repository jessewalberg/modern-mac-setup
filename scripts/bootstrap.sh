#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
umask 077

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALL_HOMEBREW=0
WITH_CLI=0
APPS_FILE=""
CONFIGURE_SHELL=0
APPLY_DEFAULTS=0
UPDATE_HOMEBREW=1
DRY_RUN=0
HOMEBREW_INSTALLER=""
HOMEBREW_INSTALLER_REF="99e13e96cbbdc1ac1ac09c0a40b450bf219ef3aa"

usage() {
  cat <<'EOF'
Usage: ./scripts/bootstrap.sh [options]

Options:
  --install-homebrew   Permit downloading and running Homebrew's official installer.
  --with-cli           Install the optional Brewfile.cli bundle.
  --apps FILE          Install an explicitly reviewed apps Brewfile.
  --configure-shell    Append the managed Homebrew/mise block to ~/.zshrc.
  --apply-defaults     Apply the narrow settings in macos-defaults.sh.
  --no-update          Skip the explicit `brew update` step.
  --dry-run            Print planned commands without changing the machine.
  -h, --help           Show this help.

The script installs only Brewfile unless optional flags are supplied.
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
  [[ "$(uname -s)" == 'Darwin' ]] || die 'This bootstrap supports macOS only.'
  [[ "$EUID" -ne 0 ]] || die 'Do not run this script as root or with sudo.'

  local translated
  translated="$(sysctl -n sysctl.proc_translated 2>/dev/null || true)"
  if [[ "$translated" == '1' ]]; then
    die 'This terminal is running under Rosetta. Relaunch Terminal natively before installing Homebrew.'
  fi

  local version major
  version="$(sw_vers -productVersion)"
  major="${version%%.*}"
  case "$major" in
    '' | *[!0-9]*)
      warn "Could not parse macOS version: $version"
      ;;
    *)
      if [[ "$major" -lt 14 ]]; then
        die "macOS $version is outside this guide's supported target. Update to macOS 14 or newer first."
      fi
      ;;
  esac

  info "macOS $version on $(uname -m)"
}

ensure_command_line_tools() {
  if xcode-select -p >/dev/null 2>&1; then
    info "Command Line Tools: $(xcode-select -p)"
    return
  fi

  warn 'Apple Command Line Tools are not installed.'
  if [[ "$DRY_RUN" -eq 1 ]]; then
    print_command xcode-select --install
  else
    xcode-select --install >/dev/null 2>&1 || true
  fi

  cat >&2 <<'EOF'
Complete the Apple installer, then run this bootstrap again. The script stops
here because Git, compilers, and Homebrew should not be installed against a
half-finished Command Line Tools installation.
EOF
  exit 2
}

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    printf '/opt/homebrew/bin/brew\n'
  elif [[ -x /usr/local/bin/brew ]]; then
    printf '/usr/local/bin/brew\n'
  else
    return 1
  fi
}

install_homebrew() {
  local existing
  existing="$(find_brew 2>/dev/null || true)"
  if [[ -n "$existing" ]]; then
    info "Homebrew already exists at $existing"
    return
  fi

  if [[ "$INSTALL_HOMEBREW" -ne 1 ]]; then
    die 'Homebrew is missing. Review this script, then rerun with --install-homebrew.'
  fi

  local installer_url
  installer_url="https://raw.githubusercontent.com/Homebrew/install/${HOMEBREW_INSTALLER_REF}/install.sh"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    info "Homebrew installer pin: ${HOMEBREW_INSTALLER_REF}"
    print_command curl -fsSL --proto '=https' --tlsv1.2 "$installer_url" -o '/tmp/homebrew-install.sh'
    print_command /bin/bash '/tmp/homebrew-install.sh'
    return
  fi

  HOMEBREW_INSTALLER="$(mktemp "${TMPDIR:-/tmp}/modern-mac-homebrew.XXXXXX")"
  info "Downloading Homebrew's installer from reviewed commit ${HOMEBREW_INSTALLER_REF}."
  curl -fsSL --proto '=https' --tlsv1.2 "$installer_url" -o "$HOMEBREW_INSTALLER"

  local checksum
  checksum="$(shasum -a 256 "$HOMEBREW_INSTALLER" | awk '{print $1}')"
  info "Downloaded installer SHA-256: $checksum"
  info "The immutable upstream commit is the trust pin; review it before updating this repository."
  run /bin/bash "$HOMEBREW_INSTALLER"
}

load_homebrew_environment() {
  local brew_bin
  brew_bin="$(find_brew 2>/dev/null || true)"

  if [[ -z "$brew_bin" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      info 'Dry run: assuming Homebrew would be available in its supported default prefix.'
      return
    fi
    die 'Homebrew installation completed but brew could not be found.'
  fi

  if [[ "$DRY_RUN" -eq 0 ]]; then
    eval "$("$brew_bin" shellenv)"
    info "Homebrew prefix: $(brew --prefix)"
  else
    print_command "$brew_bin" shellenv
  fi
}

install_bundle() {
  local file="$1"
  local label="$2"

  [[ -f "$file" ]] || die "$label file not found: $file"
  info "Installing $label from $file"
  run brew bundle install --file="$file" --no-upgrade

  if [[ "$DRY_RUN" -eq 0 ]]; then
    brew bundle check --file="$file" --no-upgrade
  fi
}

check_platform
ensure_command_line_tools
install_homebrew
load_homebrew_environment

if [[ "$UPDATE_HOMEBREW" -eq 1 ]]; then
  info 'Refreshing Homebrew metadata without upgrading installed formulae.'
  run brew update
else
  warn 'Skipping brew update by explicit request.'
fi

install_bundle "$ROOT_DIR/Brewfile" 'minimal foundation'

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
fi

if [[ "$APPLY_DEFAULTS" -eq 1 ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    run "$ROOT_DIR/scripts/macos-defaults.sh"
  else
    run "$ROOT_DIR/scripts/macos-defaults.sh" --apply
  fi
fi

cat <<'EOF'

Bootstrap complete.

Next deliberate steps:
  1. Open a new terminal if the shell snippet was installed.
  2. Set Git name and an appropriate public or private commit email.
  3. Run `gh auth login` and choose HTTPS or SSH deliberately.
  4. Pin language versions inside each project rather than globally here.
  5. Run `./scripts/audit.sh --deep` and review every warning.
EOF
