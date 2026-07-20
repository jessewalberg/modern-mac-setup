# Security and Backups

The secure baseline is manual because these controls involve recovery choices, physical possession, privacy prompts, and user intent. A shell script should not make those decisions silently.

## FileVault and recovery

Open **System Settings → Privacy & Security → FileVault** and confirm FileVault is on.

On Apple silicon and T2-equipped Macs, storage is hardware-encrypted even before FileVault is enabled, but enabling FileVault binds access to authorized credentials and strengthens protection against offline access. Choose either account-based recovery or a recovery key according to the ownership model.

For a recovery key:

- store it outside the Mac;
- do not put it in this repository, a shell history file, a screenshot folder, or an unencrypted note;
- verify it was recorded accurately before depending on it;
- understand that losing both the login credentials and recovery method can make the data unrecoverable.

Read Apple's [FileVault security architecture](https://support.apple.com/guide/security/volume-encryption-with-filevault-sec4c6dc1b6e/web) and [Mac Help instructions](https://support.apple.com/guide/mac-help/protect-data-on-your-mac-with-filevault-mh11785/mac).

## Automatic updates and background security improvements

Open **System Settings → General → Software Update → Automatic Updates** and enable the update behaviors appropriate for the machine. Also open **Privacy & Security → Background Security Improvements** and enable automatic installation.

Automatic installation does not remove the need to review major-version upgrades. Security patches and major operating-system migrations have different risk profiles and should not be treated as the same operation.

Apple documents [Background Security Improvements](https://support.apple.com/guide/mac-help/install-background-security-improvements-mchl44c4c70c/mac) separately from standard software updates.

## Firewall and sharing

Open **System Settings → Network → Firewall** and enable the application firewall. Then review its options rather than enabling “block all” without understanding application needs.

Open **System Settings → General → Sharing** and turn off services that are not deliberately used, including Remote Login, Remote Management, File Sharing, Media Sharing, and Internet Sharing. A developer may need one of these; the important property is that each listening service has an owner and purpose.

Apple's [firewall guide](https://support.apple.com/guide/mac-help/block-connections-to-your-mac-with-a-firewall-mh34041/mac) explains how signed applications and sharing services interact with the firewall.

## Screen lock and physical access

Under **Lock Screen** and **Touch ID & Password**:

- require authentication promptly after sleep or the screen saver begins;
- add only trusted fingerprints;
- avoid automatic login;
- review Apple Watch unlock according to the physical threat model;
- use a short enough idle interval for the places where the Mac is used.

Security controls should match actual environments. A stationary home desktop and a laptop used in airports have different physical exposure.

## Login items, extensions, and privacy permissions

Review **General → Login Items & Extensions**. Remove background items that have no current purpose.

Review **Privacy & Security** categories, especially:

- Accessibility;
- Full Disk Access;
- Screen & System Audio Recording;
- Input Monitoring;
- Files & Folders;
- Automation;
- Developer Tools;
- Local Network;
- Camera and Microphone.

Grant a permission when a feature is understood and needed, not simply because an installer asks. Revisit these lists during maintenance because old software often leaves privileges behind.

## Find My and activation ownership

For a personally owned Mac, Find My can support locating, locking, and erasing the device. Confirm the Apple account is recoverable and that activation ownership will be removed before sale or transfer.

Corporate and shared machines may use organizational management instead. Follow the organization's ownership and offboarding process rather than mixing personal and managed recovery paths.

## Backups

Configure Time Machine or another tested, encrypted backup before the machine accumulates irreplaceable work. Apple recommends a Time Machine disk with at least twice the Mac's storage capacity in its [Time Machine guide](https://support.apple.com/en-us/104984).

A strong baseline includes:

- one automatic local or network backup;
- one off-device or off-site copy for important data;
- version control for source code, with branches pushed or otherwise backed up;
- periodic restore tests.

Synchronization is not automatically backup. Deletion, account compromise, ransomware, or application corruption may synchronize the unwanted change.

## Run the read-only audit

After the manual review:

```bash
./scripts/audit.sh
```

The audit checks observable state such as FileVault, the firewall, Gatekeeper, SIP, Time Machine, architecture, Command Line Tools, and the package foundation. It cannot verify recovery-key storage, account recovery, backup restore quality, or whether each privacy grant is justified.

Continue with [Bootstrap](02-bootstrap.md).
