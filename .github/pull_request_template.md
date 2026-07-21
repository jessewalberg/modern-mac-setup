## Problem

Describe the recurring setup problem and the affected phase.

## Change

Explain the selected owner and why this is the smallest safe change.

## Risk review

- [ ] Architecture and Homebrew-prefix behavior reviewed
- [ ] Trust boundary and remote-download behavior reviewed
- [ ] Privilege and file-write scope reviewed
- [ ] Identity, credentials, and privacy impact reviewed
- [ ] Migration and rollback behavior documented

## Validation

- [ ] `mise run lint`
- [ ] Hosted Apple-silicon package validation
- [ ] Hosted Intel package validation
- [ ] Clean/disposable Mac acceptance test when required

Record the exact environments and expected warnings. Do not include credentials, recovery material, private hosts, serial numbers, or proprietary inventories.

## Documentation and maintenance

- [ ] README and relevant guide updated
- [ ] Catalog metadata updated when packages changed
- [ ] Troubleshooting and recovery updated
- [ ] Maintenance evidence accurately described
