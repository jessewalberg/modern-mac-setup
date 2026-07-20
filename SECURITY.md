# Security Policy

This repository contains scripts that install software and modify a small number of user preferences. Treat every change as code that may run with the current user's privileges. Homebrew's official installer may separately request administrator authorization for documented setup operations.

## Reporting a vulnerability

Use GitHub's private vulnerability reporting feature when it is enabled for this repository. When private reporting is unavailable, open a minimal issue requesting a private contact channel and omit exploit details, credentials, private hostnames, and personal data.

Do not include:

- access tokens or cookies;
- private SSH keys;
- FileVault or account recovery keys;
- passwords or multi-factor recovery codes;
- unredacted environment dumps;
- proprietary application inventories;
- device serial numbers or internal organization details.

## Scope

Security-relevant issues include:

- unintended command execution;
- unsafe quoting or path handling;
- privilege escalation;
- secret disclosure;
- insecure remote downloads;
- destructive or unexpectedly broad file changes;
- architecture confusion that installs or executes the wrong binaries;
- instructions that disable macOS security controls.

Upstream vulnerabilities in macOS, Homebrew, a formula, cask, GitHub CLI, `mise`, `uv`, or another selected application should also be reported to the relevant upstream security channel. A repository issue may be appropriate when this guide amplifies or mishandles the upstream risk.

## Supported version

Security fixes apply to the current `main` branch. The repository does not publish a long-term-support branch or guarantee safe operation on macOS versions outside the documented target.
