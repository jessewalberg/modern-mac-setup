#!/bin/bash

# Shared platform helpers for the macOS bootstrap and audit scripts.
# This file is sourced; callers own error handling and shell options.

modern_mac_validate_test_root() {
  if [[ -z "${MODERN_MAC_TEST_ROOT:-}" ]]; then
    return 0
  fi

  if [[ "${MODERN_MAC_TESTING:-0}" != '1' ]]; then
    printf '[ERROR] MODERN_MAC_TEST_ROOT is reserved for the test suite.\n' >&2
    return 1
  fi

  case "$MODERN_MAC_TEST_ROOT" in
    /*) return 0 ;;
    *)
      printf '[ERROR] MODERN_MAC_TEST_ROOT must be an absolute path.\n' >&2
      return 1
      ;;
  esac
}

modern_mac_root_path() {
  local logical_path="$1"

  if [[ -n "${MODERN_MAC_TEST_ROOT:-}" ]]; then
    printf '%s%s\n' "${MODERN_MAC_TEST_ROOT%/}" "$logical_path"
  else
    printf '%s\n' "$logical_path"
  fi
}

modern_mac_expected_brew_prefix_for_arch() {
  case "$1" in
    arm64) printf '/opt/homebrew\n' ;;
    x86_64) printf '/usr/local\n' ;;
    *) return 1 ;;
  esac
}

modern_mac_secondary_brew_prefix_for_arch() {
  case "$1" in
    arm64) printf '/usr/local\n' ;;
    x86_64) printf '/opt/homebrew\n' ;;
    *) return 1 ;;
  esac
}

modern_mac_expected_brew_bin_for_arch() {
  local prefix
  prefix="$(modern_mac_expected_brew_prefix_for_arch "$1")" || return 1
  modern_mac_root_path "${prefix}/bin/brew"
}

modern_mac_secondary_brew_bin_for_arch() {
  local prefix
  prefix="$(modern_mac_secondary_brew_prefix_for_arch "$1")" || return 1
  modern_mac_root_path "${prefix}/bin/brew"
}

modern_mac_firewall_bin() {
  modern_mac_root_path '/usr/libexec/ApplicationFirewall/socketfilterfw'
}

modern_mac_is_translated() {
  [[ "$(sysctl -n sysctl.proc_translated 2>/dev/null || true)" == '1' ]]
}
