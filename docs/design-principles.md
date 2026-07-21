# Design Principles

## 1. Recovery precedes convenience

The first setup problem is not package installation. It is proving that data, identity, and account recovery survive loss, migration, or a failed change.

## 2. Bootstrap dependencies must be acyclic

Apple Command Line Tools provide Git and clang before Homebrew exists. Apple Git clones and verifies this repository. Homebrew then installs the selected foundation. Homebrew Git is optional rather than a hidden prerequisite.

A setup that requires its own not-yet-installed package manager or Git executable is not bootstrappable from a new Mac.

## 3. One owner per responsibility

- macOS owns operating-system updates and built-in security controls;
- Apple Command Line Tools own bootstrap Git and clang;
- Homebrew owns selected machine-level formulae and applications;
- `uv` owns Python project environments and Python tools;
- `mise` owns project-pinned non-Python runtimes and this repository's development tools;
- each project owns required versions and lockfiles;
- a password manager or approved secrets system owns secrets.

Overlapping owners create drift: two Homebrew prefixes, several Python managers, competing container desktops, or both global and project-local versions of the same tool.

## 4. A small default minimizes long-term cost

Every default package adds transitive dependencies, update work, supply-chain relationships, disk use, and a future migration decision. The default Homebrew foundation contains three tools. Apple Git is already present through the prerequisite developer tools.

Everything else must justify itself in an optional layer.

## 5. Native architecture is an invariant

An Apple-silicon process uses `/opt/homebrew`; a native Intel process uses `/usr/local`. The bootstrap derives one correct path and rejects a conflicting `brew` in `PATH` rather than guessing.

Rosetta is allowed only for a named legacy application with an exit plan. It is not a general new-Mac prerequisite.

## 6. Presence is not health

An executable bit does not prove a tool works. Audits and CI run version or diagnostic commands, preserve exit status, and report the resolved path.

This avoids false `[OK]` output when a developer-tool shim, package, or authentication helper is broken.

## 7. Automation must expose trust and privilege

The repository does not run itself with `sudo`, does not use `sudo brew`, and does not install passwordless sudo rules. Homebrew's official installer may request administrator authorization for its documented initial setup.

Remote code is downloaded to a file, pinned to an immutable upstream commit, checked against a reviewed Git blob, and only then executed.

## 8. State-changing operations must be bounded and rerunnable

Scripts change named files, packages, or preference keys. They back up user-owned configuration before replacement, reject malformed state, and make optional behavior explicit through flags.

Idempotence means a second run converges without duplicate shell blocks or unrelated upgrades; it does not mean every external installer is perfectly reversible.

## 9. Secrets and identity are never defaults

A public setup repository must not contain tokens, private keys, recovery material, personal email addresses, internal hosts, VPN details, or device identifiers. Authentication and authorship require deliberate user decisions after the foundation is installed.

## 10. Evidence must be described accurately

A mocked Linux test, a pre-provisioned GitHub-hosted Mac, and a clean retail Mac prove different things. Documentation names each evidence class and does not market a hosted package test as a clean-machine bootstrap.

## 11. Current recommendations require recurring human judgment

Automation can detect missing tokens, broken commands, inconsistent declarations, and upstream releases. It cannot decide whether a vendor remains trustworthy, a license remains appropriate, or a permission request remains justified.

Quarterly editorial review and annual clean-machine acceptance complement continuous checks.
