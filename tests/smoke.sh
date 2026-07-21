#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/modern-mac-tests.XXXXXX")"
MOCK_BIN="$TEMP_ROOT/bin"
TEST_HOME="$TEMP_ROOT/home"
TEST_ROOT="$TEMP_ROOT/root"
APPLE_BIN="$TEMP_ROOT/apple-bin"
SYSTEM_BIN="$TEMP_ROOT/system-bin"
EXPECTED_BIN="$TEST_ROOT/opt/homebrew/bin"
SECONDARY_BIN="$TEST_ROOT/usr/local/bin"
FIREWALL_BIN="$TEST_ROOT/usr/libexec/ApplicationFirewall/socketfilterfw"
TEST_PATH="$EXPECTED_BIN:$MOCK_BIN:$SYSTEM_BIN"

cleanup() {
  rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT HUP INT TERM

fail() {
  printf '[FAIL] %s\n' "$*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  grep -Fq -- "$needle" <<<"$haystack" || fail "Expected output to contain: $needle"
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  if grep -Fq -- "$needle" <<<"$haystack"; then
    fail "Expected output not to contain: $needle"
  fi
}

assert_file_contains() {
  local file="$1"
  local needle="$2"
  grep -Fq -- "$needle" "$file" || fail "Expected $file to contain: $needle"
}

run_setup() {
  env \
    MODERN_MAC_TESTING=1 \
    MODERN_MAC_TEST_ROOT="$TEST_ROOT" \
    HOME="$TEST_HOME" \
    PATH="$TEST_PATH" \
    "$@"
}

mkdir -p "$MOCK_BIN" "$TEST_HOME" "$TEST_ROOT" "$APPLE_BIN" "$SYSTEM_BIN" \
  "$EXPECTED_BIN" "$SECONDARY_BIN" "$(dirname "$FIREWALL_BIN")"

# Build a minimal system PATH so host-installed gh, mise, uv, or brew cannot
# change preflight expectations on developer machines or GitHub runners.
for command_name in awk cat chmod cmp cp date diff dirname env find grep head \
  mkdir mktemp mv rm ruby sed tr wc; do
  command_path="$(command -v "$command_name")" ||
    fail "Required host command is unavailable for tests: $command_name"
  ln -s "$command_path" "$SYSTEM_BIN/$command_name"
done

cat >"$MOCK_BIN/uname" <<'STUB'
#!/bin/bash
case "${1:-}" in
  -s) printf 'Darwin\n' ;;
  -m) printf '%s\n' "${MOCK_ARCH:-arm64}" ;;
  *) printf 'Darwin\n' ;;
esac
STUB

cat >"$MOCK_BIN/sw_vers" <<'STUB'
#!/bin/bash
case "${1:-}" in
  -productVersion) printf '%s\n' "${MOCK_MACOS_VERSION:-26.1}" ;;
  -buildVersion) printf '25B78\n' ;;
  *) printf 'ProductName:\tmacOS\nProductVersion:\t%s\nBuildVersion:\t25B78\n' "${MOCK_MACOS_VERSION:-26.1}" ;;
esac
STUB

cat >"$MOCK_BIN/sysctl" <<'STUB'
#!/bin/bash
if [[ "${MOCK_TRANSLATED:-0}" == '1' ]]; then
  printf '1\n'
else
  printf '0\n'
fi
STUB

cat >"$MOCK_BIN/xcode-select" <<'STUB'
#!/bin/bash
case "${1:-}" in
  -p)
    [[ "${MOCK_CLT_MISSING:-0}" != '1' ]] || exit 1
    printf '/Library/Developer/CommandLineTools\n'
    ;;
  --install)
    printf 'installer requested\n'
    ;;
  *) exit 1 ;;
esac
STUB

cat >"$MOCK_BIN/xcrun" <<XCRUN_STUB
#!/bin/bash
if [[ "\${1:-}" == '--find' ]]; then
  case "\${2:-}" in
    git) printf '%s\\n' '$MOCK_BIN/git' ;;
    clang) printf '%s\\n' '$APPLE_BIN/clang' ;;
    *) exit 1 ;;
  esac
else
  exit 1
fi
XCRUN_STUB

cat >"$APPLE_BIN/git" <<'STUB'
#!/bin/bash
if [[ "${MOCK_APPLE_GIT_FAIL:-0}" == '1' ]]; then
  printf 'fatal: Apple Git is unavailable\n' >&2
  exit 69
fi
case "${1:-}" in
  --version) printf 'git version 2.50.1 (Apple Git-155)\n' ;;
  hash-object) printf 'c9778f3ef27abce4b907d17b8a736cc9a5861073\n' ;;
  *) printf 'mock Apple Git\n' ;;
esac
STUB

ln -s "$APPLE_BIN/git" "$MOCK_BIN/git"

cat >"$APPLE_BIN/clang" <<'STUB'
#!/bin/bash
if [[ "${MOCK_CLANG_FAIL:-0}" == '1' ]]; then
  printf 'clang: unavailable\n' >&2
  exit 70
fi
printf 'Apple clang version 17.0.0\n'
STUB

cat >"$MOCK_BIN/fdesetup" <<'STUB'
#!/bin/bash
printf 'FileVault is On.\n'
STUB

cat >"$MOCK_BIN/spctl" <<'STUB'
#!/bin/bash
printf 'assessments enabled\n'
STUB

cat >"$MOCK_BIN/csrutil" <<'STUB'
#!/bin/bash
printf 'System Integrity Protection status: enabled.\n'
STUB

cat >"$MOCK_BIN/tmutil" <<'STUB'
#!/bin/bash
printf '====================================================\nName          : Test Backup\n'
STUB

cat >"$FIREWALL_BIN" <<'STUB'
#!/bin/bash
printf 'Firewall is enabled. (State = 1)\n'
STUB

write_brew() {
  local destination="$1"
  local logical_prefix="$2"
  local destination_dir
  destination_dir="$(dirname "$destination")"
  mkdir -p "$destination_dir"
  cat >"$destination" <<BREW_STUB
#!/bin/bash
case "\${1:-}" in
  --prefix)
    printf '%s\\n' '$logical_prefix'
    ;;
  --version)
    printf 'Homebrew 4.6.0\\n'
    ;;
  shellenv)
    printf 'export HOMEBREW_PREFIX=%q\\n' '$logical_prefix'
    printf 'export PATH=%q:\\$PATH\\n' '$destination_dir'
    ;;
  update)
    printf 'Already up-to-date.\\n'
    ;;
  bundle)
    exit "\${MOCK_BUNDLE_STATUS:-0}"
    ;;
  doctor)
    exit "\${MOCK_BREW_DOCTOR_STATUS:-0}"
    ;;
  *)
    exit 0
    ;;
esac
BREW_STUB
  chmod +x "$destination"
}

write_command() {
  local name="$1"
  local version="$2"
  cat >"$EXPECTED_BIN/$name" <<COMMAND_STUB
#!/bin/bash
if [[ "\${MOCK_FAIL_COMMAND:-}" == '$name' ]]; then
  printf 'fatal: $name is broken\\n' >&2
  exit 69
fi
case "\${1:-}" in
  --version) printf '%s\\n' '$version' ;;
  doctor) exit 0 ;;
  auth)
    [[ "\${2:-}" == 'status' ]] && exit 0
    ;;
  *) exit 0 ;;
esac
COMMAND_STUB
  chmod +x "$EXPECTED_BIN/$name"
}

reset_homebrew() {
  rm -f "$EXPECTED_BIN/brew" "$SECONDARY_BIN/brew"
  rm -f "$EXPECTED_BIN/gh" "$EXPECTED_BIN/mise" "$EXPECTED_BIN/uv" "$EXPECTED_BIN/git"
  write_brew "$EXPECTED_BIN/brew" '/opt/homebrew'
  write_command gh 'gh version 2.76.0'
  write_command mise '2026.7.1 macos-arm64'
  write_command uv 'uv 0.8.0'
}

chmod +x "$MOCK_BIN"/* "$APPLE_BIN"/* "$FIREWALL_BIN"
reset_homebrew

# The normal dry run must use the architecture-correct Homebrew executable and
# include only explicitly selected layers.
output="$(run_setup "$ROOT_DIR/scripts/bootstrap.sh" --dry-run --with-cli --with-homebrew-git --configure-shell --apply-defaults 2>&1)"
assert_contains "$output" "$EXPECTED_BIN/brew bundle install"
assert_contains "$output" 'Brewfile.git'
assert_contains "$output" 'Brewfile.cli'
assert_contains "$output" 'configure-shell.sh --dry-run'
assert_contains "$output" 'macos-defaults.sh'
assert_contains "$output" 'Apple Command Line Tools own the bootstrap/default Git'
assert_not_contains "$output" "$SECONDARY_BIN/brew bundle install"
[[ ! -e "$TEST_HOME/.zshrc" ]] || fail 'Bootstrap dry run created .zshrc.'

# Missing Homebrew is never installed without explicit consent.
rm -f "$EXPECTED_BIN/brew"
if output="$(run_setup "$ROOT_DIR/scripts/bootstrap.sh" --dry-run 2>&1)"; then
  fail 'Bootstrap accepted missing Homebrew without --install-homebrew.'
fi
assert_contains "$output" 'rerun with --install-homebrew'

output="$(run_setup "$ROOT_DIR/scripts/bootstrap.sh" --dry-run --install-homebrew --configure-shell 2>&1)"
assert_contains "$output" '99e13e96cbbdc1ac1ac09c0a40b450bf219ef3aa'
assert_contains "$output" 'c9778f3ef27abce4b907d17b8a736cc9a5861073'
assert_contains "$output" 'raw.githubusercontent.com/Homebrew/install/'
reset_homebrew

# A native process must not accept an Intel-prefix Homebrew in PATH or as the
# only installation.
rm -f "$EXPECTED_BIN/brew"
write_brew "$SECONDARY_BIN/brew" '/usr/local'
if output="$(env MODERN_MAC_TESTING=1 MODERN_MAC_TEST_ROOT="$TEST_ROOT" HOME="$TEST_HOME" PATH="$SECONDARY_BIN:$MOCK_BIN:$SYSTEM_BIN" "$ROOT_DIR/scripts/bootstrap.sh" --dry-run --install-homebrew 2>&1)"; then
  fail 'Bootstrap accepted only the other-architecture Homebrew.'
fi
assert_contains "$output" 'other architecture prefix /usr/local'
reset_homebrew

# A stale Intel Homebrew that precedes the native installation in PATH is an
# error rather than something the bootstrap silently works around.
write_brew "$SECONDARY_BIN/brew" '/usr/local'
if output="$(env MODERN_MAC_TESTING=1 MODERN_MAC_TEST_ROOT="$TEST_ROOT" HOME="$TEST_HOME" PATH="$SECONDARY_BIN:$EXPECTED_BIN:$MOCK_BIN:$SYSTEM_BIN" "$ROOT_DIR/scripts/bootstrap.sh" --dry-run 2>&1)"; then
  fail 'Bootstrap accepted a wrong-prefix brew earlier in PATH.'
fi
assert_contains "$output" 'brew in PATH resolves to'
assert_contains "$output" 'requires /opt/homebrew'
rm -f "$SECONDARY_BIN/brew"

# Command Line Tools must be usable, not just selected.
if output="$(MOCK_APPLE_GIT_FAIL=1 run_setup "$ROOT_DIR/scripts/bootstrap.sh" --dry-run 2>&1)"; then
  fail 'Bootstrap accepted an Apple Git executable that fails.'
fi
assert_contains "$output" 'Apple Git exists'
assert_contains "$output" 'could not run'

set +e
output="$(MOCK_CLT_MISSING=1 run_setup "$ROOT_DIR/scripts/bootstrap.sh" --dry-run 2>&1)"
status=$?
set -e
[[ "$status" -eq 2 ]] || fail "Expected missing CLT exit 2, got $status"
assert_contains "$output" 'xcode-select --install'
assert_contains "$output" 'Complete Apple'

# Preflight is successful without Homebrew foundation packages and labels their
# absence as informational rather than failed postconditions.
rm -f "$EXPECTED_BIN/brew" "$EXPECTED_BIN/gh" "$EXPECTED_BIN/mise" "$EXPECTED_BIN/uv"
output="$(run_setup "$ROOT_DIR/scripts/audit.sh" --preflight 2>&1)"
assert_contains "$output" 'Mode: preflight'
assert_contains "$output" 'Native Homebrew is not installed yet'
assert_contains "$output" 'Summary: 0 error(s), 0 warning(s).'
assert_not_contains "$output" '[OK]    GitHub CLI'
reset_homebrew

# Post-bootstrap verifies executable behavior and reports exact paths.
output="$(run_setup "$ROOT_DIR/scripts/audit.sh" --post-bootstrap --deep 2>&1)"
assert_contains "$output" 'Mode: post-bootstrap'
assert_contains "$output" 'Homebrew prefix matches arm64: /opt/homebrew'
assert_contains "$output" "GitHub CLI: gh version 2.76.0 ($EXPECTED_BIN/gh)"
assert_contains "$output" 'Summary: 0 error(s), 0 warning(s).'

# A command that exists but fails must be an error, never an OK line.
set +e
output="$(MOCK_FAIL_COMMAND=gh run_setup "$ROOT_DIR/scripts/audit.sh" --post-bootstrap 2>&1)"
status=$?
set -e
[[ "$status" -ne 0 ]] || fail 'Audit accepted a broken GitHub CLI.'
assert_contains "$output" 'GitHub CLI exists'
assert_contains "$output" 'fatal: gh is broken'
assert_not_contains "$output" '[OK]    GitHub CLI: fatal: gh is broken'

# The catalog verification command likewise executes --version rather than only
# checking that an executable bit exists.
set +e
output="$(env PATH="$EXPECTED_BIN:$SYSTEM_BIN" MOCK_FAIL_COMMAND=uv ruby "$ROOT_DIR/scripts/verify-installed.rb" foundation 2>&1)"
status=$?
set -e
[[ "$status" -ne 0 ]] || fail 'verify-installed accepted a broken uv command.'
assert_contains "$output" 'uv exists'
assert_contains "$output" '--version failed'

# The managed shell block is upgraded in place, backed up, and idempotent.
cat >"$TEST_HOME/.zshrc" <<'EOF_ZSH'
export BEFORE=1
# >>> modern-mac-setup >>>
# managed-version: 1
export OLD_SETUP=1
# <<< modern-mac-setup <<<
export AFTER=1
EOF_ZSH
run_setup "$ROOT_DIR/scripts/configure-shell.sh" >/dev/null
assert_file_contains "$TEST_HOME/.zshrc" '# managed-version: 2'
assert_file_contains "$TEST_HOME/.zshrc" 'export BEFORE=1'
assert_file_contains "$TEST_HOME/.zshrc" 'export AFTER=1'
if grep -Fq 'OLD_SETUP' "$TEST_HOME/.zshrc"; then
  fail 'Old managed shell content was not replaced.'
fi
backup_count="$(find "$TEST_HOME" -maxdepth 1 -name '.zshrc.backup.*' | wc -l | tr -d ' ')"
[[ "$backup_count" -eq 1 ]] || fail 'Expected exactly one shell backup after update.'
run_setup "$ROOT_DIR/scripts/configure-shell.sh" >/dev/null
backup_count="$(find "$TEST_HOME" -maxdepth 1 -name '.zshrc.backup.*' | wc -l | tr -d ' ')"
[[ "$backup_count" -eq 1 ]] || fail 'Idempotent shell rerun created another backup.'
[[ "$(grep -Fxc '# >>> modern-mac-setup >>>' "$TEST_HOME/.zshrc")" -eq 1 ]] || fail 'Managed shell start marker count is not one.'

# Malformed managed state and symlinked dotfiles are left untouched.
printf '# >>> modern-mac-setup >>>\n' >"$TEST_HOME/.zshrc"
if output="$(run_setup "$ROOT_DIR/scripts/configure-shell.sh" 2>&1)"; then
  fail 'configure-shell accepted malformed markers.'
fi
assert_contains "$output" 'malformed or duplicated managed block'
rm -f "$TEST_HOME/.zshrc"
printf 'source file\n' >"$TEST_HOME/source-zshrc"
ln -s "$TEST_HOME/source-zshrc" "$TEST_HOME/.zshrc"
if output="$(run_setup "$ROOT_DIR/scripts/configure-shell.sh" 2>&1)"; then
  fail 'configure-shell replaced a symlinked .zshrc.'
fi
assert_contains "$output" 'is a symlink'
rm -f "$TEST_HOME/.zshrc"

# Preference preview remains read-only.
run_setup "$ROOT_DIR/scripts/macos-defaults.sh" >/dev/null
[[ ! -d "$TEST_HOME/Pictures/Screenshots" ]] || fail 'macOS defaults dry run created the screenshot directory.'

printf '[OK] Professional hardening smoke tests passed.\n'
