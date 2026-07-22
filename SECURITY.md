# Security Policy

This repository installs software and can modify a few user preferences. Treat every change as code running with the current user's privileges. Homebrew's official installer may separately request administrator authorization for its documented setup.

## Report a vulnerability

Use GitHub private vulnerability reporting when available. Otherwise, open a minimal issue requesting a private contact channel and omit exploit details or sensitive data.

Never post tokens, cookies, passwords, private keys, FileVault or account recovery material, unredacted environment dumps, serial numbers, internal hosts, private repository names, or customer data.

Relevant issues include unintended command execution, unsafe path handling, privilege escalation, secret disclosure, insecure downloads, destructive file changes, architecture confusion, and instructions that weaken macOS security controls.

Report upstream vulnerabilities to the relevant upstream project as well. Open an issue here when this guide amplifies or mishandles that risk.

Security fixes apply to the current `main` branch. Unsupported macOS versions are outside this repository's documented target.
