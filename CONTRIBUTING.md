# Contributing

Contributions should make the setup safer, smaller, clearer, or easier to maintain.

Read [`AGENTS.md`](AGENTS.md) before changing scripts, packages, workflows, or documentation. It contains the repository map, safety invariants, documentation rules, and maintenance policy.

Keep changes narrow. Do not add personal preferences, overlapping applications, broad package catalogs, third-party taps, credentials, disabled security controls, `sudo brew`, passwordless sudo, or unexplained recursive permission changes.

Run:

```bash
ruby scripts/validate-catalog.rb
make lint
```

A pull request should explain:

- the human problem;
- what changed and why;
- security, privacy, privilege, and platform assumptions;
- validation performed;
- rollback or recovery for state-changing behavior.

Use current primary sources for platform-sensitive claims. Update the README only when the human setup path changes; put deeper context in `docs/REFERENCE.md`.
