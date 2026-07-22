#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/modern-mac-tests.XXXXXX")"
MOCK_BIN="$TEMP_ROOT/bin"
TEST_HOME="$TEMP_ROOT/home"

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
  printf '%s' "$haystack" | grep -Fq -- "$needle" || fail "Expected output to contain: $needle"
}

mkdir -p "$MOCK_BIN" "$TEST_HOME"

cat >"$MOCK_BIN/uname" <<'STUB'
#!/bin/bash
case "${1:-}" in
  -s) printf 'Darwin\n' ;;
  -m) printf 'arm64\n' ;;
  *) printf 'Darwin\n' ;;
esac
STUB

cat >"$MOCK_BIN/sw_vers" <<'STUB'
#!/bin/bash
case "${1:-}" in
  -productVersion) printf '26.5.2\n' ;;
  -buildVersion) printf '25F100\n' ;;
  *) printf 'ProductName:\tmacOS\nProductVersion:\t26.5.2\nBuildVersion:\t25F100\n' ;;
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
if [[ "${1:-}" == '-p' ]]; then
  printf '/Library/Developer/CommandLineTools\n'
  exit 0
fi
exit 1
STUB

cat >"$MOCK_BIN/brew" <<'STUB'
#!/bin/bash
if [[ "${1:-}" == 'shellenv' ]]; then
  printf 'export HOMEBREW_PREFIX=/opt/homebrew\n'
fi
exit 0
STUB

chmod +x "$MOCK_BIN"/*

TEST_PATH="$MOCK_BIN:/usr/bin:/bin"

output="$(
  PATH="$TEST_PATH" HOME="$TEST_HOME" \
    "$ROOT_DIR/scripts/bootstrap.sh" \
    --dry-run \
    --with-cli \
    --configure-shell 2>&1
)"
assert_contains "$output" 'brew bundle install'
assert_contains "$output" '--no-upgrade'
assert_contains "$output" 'configure-shell.sh --dry-run'
[[ ! -e "$TEST_HOME/.zshrc" ]] || fail 'Bootstrap dry run created .zshrc.'

if output="$(
  PATH="$TEST_PATH" HOME="$TEST_HOME" \
    "$ROOT_DIR/scripts/bootstrap.sh" --dry-run --apply-defaults 2>&1
)"; then
  fail 'Bootstrap still accepted the removed --apply-defaults option.'
fi
assert_contains "$output" 'Unknown option: --apply-defaults'

if output="$(
  PATH="$TEST_PATH" HOME="$TEST_HOME" MOCK_TRANSLATED=1 \
    "$ROOT_DIR/scripts/bootstrap.sh" --dry-run 2>&1
)"; then
  fail 'Bootstrap accepted a Rosetta-translated process.'
fi
assert_contains "$output" 'running under Rosetta'

mv "$MOCK_BIN/brew" "$MOCK_BIN/brew.disabled"
if output="$(
  PATH="$TEST_PATH" HOME="$TEST_HOME" \
    "$ROOT_DIR/scripts/bootstrap.sh" --dry-run 2>&1
)"; then
  fail 'Bootstrap installed missing Homebrew without explicit permission.'
fi
assert_contains "$output" 'rerun with --install-homebrew'

output="$(
  PATH="$TEST_PATH" HOME="$TEST_HOME" \
    "$ROOT_DIR/scripts/bootstrap.sh" --dry-run --install-homebrew 2>&1
)"
assert_contains "$output" '99e13e96cbbdc1ac1ac09c0a40b450bf219ef3aa'
assert_contains "$output" 'raw.githubusercontent.com/Homebrew/install/'
mv "$MOCK_BIN/brew.disabled" "$MOCK_BIN/brew"

printf 'export TEST_VALUE=1\n' >"$TEST_HOME/.zshrc"
PATH="$TEST_PATH" HOME="$TEST_HOME" "$ROOT_DIR/scripts/configure-shell.sh" >/dev/null
first_copy="$TEMP_ROOT/zshrc.first"
cp "$TEST_HOME/.zshrc" "$first_copy"
PATH="$TEST_PATH" HOME="$TEST_HOME" "$ROOT_DIR/scripts/configure-shell.sh" >/dev/null
cmp -s "$first_copy" "$TEST_HOME/.zshrc" || fail 'Shell configuration was not idempotent.'
[[ "$(grep -Fc '# >>> modern-mac-setup >>>' "$TEST_HOME/.zshrc")" -eq 1 ]] || fail 'Managed shell marker count is not one.'
find "$TEST_HOME" -maxdepth 1 -name '.zshrc.backup.*' -print -quit | grep -q . || fail 'Shell configuration did not create a backup.'

output="$(
  PATH="$TEST_PATH" HOME="$TEST_HOME" \
    "$ROOT_DIR/scripts/macos-defaults.sh" 2>&1
)"
assert_contains "$output" 'Show all filename extensions'
assert_contains "$output" 'Finder > Settings > Advanced'
assert_contains "$output" 'Show the Finder path bar'
assert_contains "$output" 'Show the Finder status bar'
assert_contains "$output" 'Existing screenshots and recordings are not moved'
assert_contains "$output" 'Finder and SystemUIServer'
assert_contains "$output" 'defaults write NSGlobalDomain AppleShowAllExtensions'
[[ ! -d "$TEST_HOME/Pictures/Screenshots" ]] || fail 'macOS defaults dry run created the screenshot directory.'

printf '[OK] Linux smoke tests passed.\n'
