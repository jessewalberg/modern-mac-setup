# Security and Backups

The secure baseline is manual because recovery choices, physical possession, privacy prompts, and user intent should not be delegated to an unattended shell script.

## FileVault and recovery

Open **System Settings → Privacy & Security → FileVault** and confirm FileVault is on.

On Apple silicon and T2-equipped Macs, storage is hardware-encrypted before FileVault is enabled, but FileVault binds access to authorized credentials and strengthens protection against offline access. Choose account-based recovery or a recovery key according to the ownership model.

For a recovery key:

- store it outside the Mac;
- do not put it in this repository, shell history, screenshots, or an unencrypted note;
- verify it was recorded accurately before depending on it;
- understand that losing both login credentials and recovery material can make data unrecoverable.

Read Apple's [FileVault security architecture](https://support.apple.com/guide/security/volume-encryption-with-filevault-sec4c6dc1b6e/web) and [Mac Help instructions](https://support.apple.com/guide/mac-help/protect-data-on-your-mac-with-filevault-mh11785/mac).

## Automatic updates and background security improvements

Open **System Settings → General → Software Update → Automatic Updates** and enable the security-update behavior appropriate for the machine.

The label **Background Security Improvements** is version-dependent:

- on macOS 26.1 or later, open **Privacy & Security → Background Security Improvements** and enable automatic installation;
- on macOS 14, 15, or macOS 26.0, use the automatic security and system-data update controls presented under Software Update.

Do not interpret this as permission to apply every major-version upgrade without review. Rapid security responses, patch releases, and major operating-system migrations have different compatibility risk.

Apple documents [Background Security Improvements](https://support.apple.com/guide/mac-help/install-background-security-improvements-mchl44c4c70c/mac) separately from standard software updates.

## Firewall and sharing

Open **System Settings → Network → Firewall** and enable the application firewall when it fits the machine's network and application requirements. Review the options rather than enabling “block all” without understanding the impact.

Open **System Settings → General → Sharing** and turn off services that are not deliberately used, including Remote Login, Remote Management, File Sharing, Media Sharing, and Internet Sharing. A developer may need one of these; every listening service should have a named owner and purpose.

Apple's [firewall guide](https://support.apple.com/guide/mac-help/block-connections-to-your-mac-with-a-firewall-mh34041/mac) explains how signed applications and sharing services interact with the firewall.

## Screen lock and physical access

Under **Lock Screen** and **Touch ID & Password**:

- require authentication promptly after sleep or screen saver;
- add only trusted fingerprints;
- avoid automatic login;
- review Apple Watch unlock according to the physical threat model;
- choose an idle interval appropriate for where the Mac is used.

A stationary home desktop and a laptop used in airports have different exposure. Document the intended context rather than copying one universal timeout.

## Login items, extensions, and privacy permissions

Review **General → Login Items & Extensions**. Remove background items with no current purpose.

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

Grant a permission only when the feature is understood and needed. Revisit these lists during maintenance because removed software can leave privileges or helper components behind.

## Find My and activation ownership

For a personally owned Mac, Find My can support locating, locking, and erasing the device. Confirm the Apple account is recoverable and remove activation ownership before sale or transfer.

Corporate and shared machines may use organizational management instead. Follow the organization's enrollment and offboarding process rather than mixing personal and managed recovery paths.

## Backups

Configure Time Machine or another tested, encrypted backup before the machine accumulates irreplaceable work. Apple's [Time Machine guide](https://support.apple.com/en-us/104984) recommends a destination with enough capacity for retained history.

A strong baseline includes:

- one automatic local or network backup;
- one off-device or off-site copy for important data;
- version control for source code, with important branches pushed or otherwise backed up;
- periodic restore tests.

Synchronization is not automatically backup. Deletion, account compromise, ransomware, and application corruption can synchronize the unwanted state.

## Run the preflight audit

After the manual review and Command Line Tools installation:

```bash
./scripts/audit.sh --preflight
```

The audit checks observable state such as FileVault, firewall, Gatekeeper, SIP, Time Machine, native architecture, developer tools, and Homebrew-prefix safety. It cannot verify recovery-key storage, account recovery, restore quality, or whether every privacy grant is justified.

Continue with [Bootstrap](02-bootstrap.md).
