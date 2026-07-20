# Design Principles

This repository is intentionally smaller than many fresh-install guides. The omissions are part of the design.

## 1. Recovery before productivity

The first irreversible failure on a new machine is usually lost data, locked accounts, or missing recovery material—not a missing terminal theme. FileVault, account recovery, updates, and tested backups therefore precede package installation.

## 2. Automate facts, not taste

Package declarations are suitable for automation because their desired state can be reviewed. Dock layout, key repeat, terminal themes, browser extensions, and notification choices depend on the person, hardware, and accessibility needs.

The preferences script includes only settings with a narrow effect, a clear explanation, and a recorded previous value.

## 3. A small default minimizes drift

Every default package becomes a transitive dependency, update obligation, supply-chain relationship, disk consumer, and future migration decision. The foundation contains four tools. Everything else must justify itself in a separate layer.

## 4. One owner per responsibility

- macOS owns operating-system updates and built-in security controls.
- Homebrew owns selected system-level packages and applications.
- `uv` owns Python project environments and Python tools.
- `mise` owns project-pinned non-Python runtimes and tools.
- each project owns its required versions and lockfiles.
- a password manager or approved secrets system owns secrets.

Overlapping owners create conflicts: multiple Python managers, two Homebrew prefixes, several container desktops, or both global and project-local versions of the same tool.

## 5. Native architecture by default

A new Apple-silicon Mac should run native tools from `/opt/homebrew`. The bootstrap rejects Rosetta translation to prevent accidental Intel package state. Legacy translation is added only for a named application with an exit plan.

The scripts still recognize native Intel Homebrew at `/usr/local` while supported, but the documentation does not assume Intel has an indefinite future.

## 6. No hidden privilege escalation

The repository does not run itself with `sudo`, does not run `sudo brew`, and does not install passwordless sudo rules. Homebrew's official installer may request administrator authorization for its documented initial setup.

Scripts exit when launched as root because root-owned files in a user's home directory create persistent and confusing failures.

## 7. Inspect remote code before execution

The bootstrap downloads Homebrew's official installer to a temporary file rather than piping the network response directly to Bash. The user grants that operation explicitly with `--install-homebrew`.

Package managers still execute installation logic and vendor packages. Automation narrows and records trust; it does not eliminate it.

## 8. No secrets in reproducible configuration

A public setup repository is hostile storage for secrets. The repository ignores common local secret paths, but `.gitignore` is not a security boundary. Never place private keys, tokens, recovery codes, certificates with private material, or environment secrets in the working tree.

Use templates that reference an external secrets provider. Scan staged changes before every public push.

## 9. Idempotent, additive, and reversible where practical

Rerunning package installation should converge on declared packages. Shell setup detects its managed block. Preferences are opt-in and snapshot prior values.

The repository avoids destructive “cleanup to match” operations because a public guide cannot know whether undeclared software is intentional.

## 10. Honest reproducibility

A Brewfile records names and categories, not a complete cryptographic lock of every installed artifact. `--no-upgrade` reduces surprise but does not pin missing packages to historical versions.

Strong reproducibility belongs closer to projects through lockfiles, containers, Nix, dev environments, or other appropriately scoped systems. This repository aims for a reviewable machine baseline, not an immutable workstation image.

## 11. Manual privacy grants are a feature

macOS privacy prompts are moments for informed consent. Scripts should not bypass Transparency, Consent, and Control protections or install configuration profiles to pre-authorize personal applications.

Managed organizations may use MDM for approved policy. That is a separate administrative trust model and should not be imitated by a personal setup script.

## 12. Primary sources over copied recipes

Commands are checked against Apple, Homebrew, GitHub, `mise`, and `uv` documentation. Blog posts can identify useful questions, but copied commands age quickly and often omit threat models, architecture assumptions, and rollback behavior.
