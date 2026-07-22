# Communities and Modern Tool Discovery

**Last reviewed:** July 22, 2026

A useful setup guide should point to people, not only packages. Documentation explains the supported path; communities reveal current workflows, rough edges, alternatives, and changes that have not reached older articles yet.

Community links and norms can move. Start from an official project page when possible, and treat a direct invite link as temporary rather than permanent documentation.

## Choose the right channel

| Need | Best starting point | Why |
| --- | --- | --- |
| Learn the supported workflow | Official documentation | Most durable and least likely to repeat an obsolete workaround. |
| Ask a searchable question | GitHub Discussions or an official forum | Answers remain discoverable after chat scrolls away. |
| Get conversational help | Discord, Slack, Matrix, or IRC | Good for clarification, examples, and learning how other people work. |
| Report a reproducible defect | The project's issue tracker | Maintainers can triage versions, logs, and a minimal reproduction. Check the project's rules first. |
| Compare tools and practices | User groups, Reddit, meetups, and conferences | Useful for experience reports, but verify technical claims against primary sources. |
| Follow releases | Release notes, project announcements, and repository notifications | More reliable than remembering advice from a setup guide. |

Chat is excellent for discovery but poor as the only record. When a conversation produces a durable fix, summarize it in a Discussion, issue, pull request, or project documentation when appropriate.

## Mac and Apple communities

### Mac Admins

[Mac Admins Slack](https://www.macadmins.org/) is a large, vendor-neutral community for people who deploy, secure, support, and automate Macs. It is especially useful for FileVault, identity, device management, networking, packaging, security controls, and understanding how macOS behavior changes across releases.

You do not need to manage a fleet to learn from it, but search existing channels and respect each channel's scope before posting.

### Apple Developer Forums

[Apple Developer Forums](https://developer.apple.com/forums/) is the durable place for questions about Apple frameworks, command-line tools, signing, notarization, sandboxing, Xcode, and OS-level behavior. It is a better first stop than a general chat when the answer depends on a supported Apple API or platform rule.

## Terminals and editors

### cmux

[cmux](https://cmux.com/) is a native macOS terminal workspace built around Ghostty. It is aimed at people running multiple projects or coding agents and combines terminal sessions with workspaces, notifications, browser panes, and command-line control.

- [Community hub](https://cmux.com/community): official links to Discord, GitHub, social channels, videos, and updates.
- [Documentation](https://cmux.com/docs): installation, features, commands, and supported behavior.
- [GitHub repository](https://github.com/manaflow-ai/cmux): source, issues, releases, and contributions.

The commented application Brewfile includes `cask "cmux"`. Terminal.app remains sufficient for bootstrap, so install cmux only when its workspace and agent-oriented workflow solves a real problem.

### Ghostty

[Ghostty](https://ghostty.org/) is a focused terminal emulator and the terminal foundation used by cmux.

- [Community and support](https://ghostty.org/docs/help): points users to GitHub Discussions and a community-moderated Discord.
- Use Discussions for searchable help and design conversation; follow the project's guidance before opening an issue.

Using cmux does not require also installing the standalone Ghostty application. They overlap at the terminal layer but present different workflows.

### Zed

[Zed support](https://zed.dev/support) points to its official Discord for conversational help, GitHub Issues for confirmed bugs and requests, and Reddit for broader user discussion. Its channel guidance distinguishes new-user questions, support, and possible bugs before escalation.

## Package and runtime communities

### Homebrew

[Homebrew Discussions](https://github.com/orgs/Homebrew/discussions) is a better place for installation and package-manager questions than copying a workaround from an old blog post. Formula- or cask-specific defects may ultimately belong in the relevant Homebrew repository after following its issue template.

### mise

[mise Discussions](https://github.com/jdx/mise/discussions) includes announcements, ideas, troubleshooting, and bug-report conversations. Project-specific runtime versions should still live in project configuration; the community is useful for resolving plugin, backend, and activation behavior.

### Astral and uv

The [Astral community Discord](https://discord.com/invite/astral-sh) covers the ecosystem behind tools such as uv and Ruff. Prefer the [uv documentation](https://docs.astral.sh/uv/) for supported commands, then use community conversation for examples or unresolved behavior.

## Containers and local infrastructure

Container communities differ, which is one reason this repository does not install a platform by default.

- [Docker Community](https://www.docker.com/community/) lists the official forum, meetups, and community Slack. Docker labels Reddit, Stack Overflow, and Discord as community-led rather than official support.
- [OrbStack support](https://docs.orbstack.dev/help) points to GitHub Discussions for searchable help, an issue tracker for defects and requests, and Discord for community conversation.
- [Podman Community](https://podman.io/community/) offers Matrix, IRC, GitHub Discussions, Discord, meetings, and a mailing list. Choose the medium that matches whether the question is conversational, durable, or contributor-focused.

## Discord and Slack are optional applications

A browser is enough for occasional community access. Desktop chat clients add notifications, background activity, local caches, account sessions, and another update channel.

The commented application Brewfile offers:

```ruby
cask "discord"
cask "slack"
```

Uncomment only the client used regularly. Review notification settings, login items, microphone and camera access, screen sharing, downloaded files, and workspace retention policies after signing in. Neither application is part of the default setup.

## Ask safely and effectively

Before posting logs, screenshots, configuration, or agent output:

1. Remove tokens, API keys, cookies, private keys, recovery keys, serial numbers, personal paths, private repository names, internal hosts, and customer data.
2. State the macOS version, hardware architecture, application version, installation owner, and exact command.
3. Include a small reproduction and the complete error message rather than a paraphrase.
4. Explain what you expected, what happened, and what you already tried.
5. Search the documentation, Discussions, forum, and issue tracker first.
6. Move a confirmed bug into the project's requested tracker rather than leaving it only in chat.
7. Return with the resolution when possible so the next person can find it.

Communities help discover what is current; they do not replace review. Verify commands before running them, especially commands involving `sudo`, security settings, package sources, credentials, cloud accounts, or destructive operations.
