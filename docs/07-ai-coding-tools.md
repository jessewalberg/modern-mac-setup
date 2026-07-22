# Optional AI Coding Tools

**Last reviewed:** July 22, 2026

No AI editor or coding agent is required for this setup, and none is installed by default. These tools can read source code, edit files, and in many cases run shell commands. Start with one, learn its trust and approval model, and add another only when it solves a different problem.

## Decision checklist

Use this as a decision worksheet, not an install-everything list.

- [ ] Keep the editor already used by the project or team unless a different workflow has a clear benefit.
- [ ] Choose at most one visual editor or agent workspace to evaluate first.
- [ ] Choose zero or one terminal coding agent to evaluate first.
- [ ] Confirm whether access comes from a subscription, organization policy, or separately billed API key.
- [ ] Review what source code, prompts, logs, and telemetry may leave the Mac.
- [ ] Understand the tool's workspace-trust, file-write, shell-command, network, and approval settings.
- [ ] Choose one installation and update owner; do not install the same tool through both a vendor installer and Homebrew.
- [ ] Start in a trusted repository with a clean Git status and a recoverable branch or worktree.
- [ ] Keep secrets, `.env` files, credentials, and private keys out of prompts and agent-readable paths where practical.
- [ ] Add no MCP server, plugin, hook, skill, or extension until its code and permissions have been reviewed.

## Choose a visual workspace

| Option | Best fit | Important distinction |
| --- | --- | --- |
| [Visual Studio Code](https://code.visualstudio.com/docs) | Established editor, debugging, notebooks, remote development, and a broad extension ecosystem | AI can remain an optional layer; current VS Code agent surfaces can work with Copilot and supported third-party agents. |
| [Zed](https://zed.dev/docs) | Native, fast editor with built-in review tools and local or external agents | Its Agent Panel can use Zed's agent or ACP-compatible external agents, with tool permissions and worktree isolation. |
| [Cursor](https://cursor.com/docs) | AI-first editor for people who want agent workflows integrated into editing | The Cursor app and Cursor CLI overlap. Install both only when separate editor and terminal workflows are useful. |
| [Google Antigravity](https://antigravity.google/product/antigravity-2) | Visual orchestration of multiple agents and projects | It is an agent workspace rather than a neutral code editor; review account, data-use, scheduling, skills, hooks, and MCP settings. |

The commented application example supports all four:

```ruby
cask "visual-studio-code"
cask "zed"
cask "cursor"
cask "antigravity"
```

Uncomment only the selected option in your local `Brewfile.apps`.

## Choose one terminal agent to start

| Tool | Start command | Good fit | Installation and account notes |
| --- | --- | --- | --- |
| [Claude Code](https://code.claude.com/docs/en/overview) | `claude` | Terminal-first work with Anthropic models and project-aware editing | Anthropic recommends its native installer, which auto-updates. The example instead offers Homebrew's delayed stable channel for people who deliberately want Brewfile ownership. The `claude` desktop cask is a separate chat application. |
| [Codex CLI](https://developers.openai.com/codex/cli/) | `codex` | Local terminal agent with OpenAI account or API access | Available as an official Homebrew cask. Review approval and sandbox settings before increasing autonomy. |
| [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/cli-getting-started) | `copilot` | GitHub-centered workflows and teams already using Copilot | Requires Copilot access; organization-managed accounts may also require the CLI policy to be enabled. It asks users to trust a folder and approve changes. |
| [Google Antigravity CLI](https://antigravity.google/docs/cli-overview) | `agy` | Lightweight terminal interface, SSH use, and users of the Antigravity workspace | Uses Google sign-in and shared Antigravity settings. Review workspace trust, permissions, data-use controls, plugins, hooks, skills, and MCP configuration. |
| [Cursor CLI](https://docs.cursor.com/en/cli/overview) | `cursor-agent` | Cursor's agent from a terminal or another editor | Currently beta. Interactive mode asks before commands; non-interactive mode has full write access, so do not treat it as a harmless read-only command. |
| [OpenCode](https://opencode.ai/docs) | `opencode` | Open-source, provider-flexible terminal agent | The public example uses Homebrew core and no third-party tap. OpenCode's own tap is normally newer, so the core formula can lag upstream. Provider credentials remain the user's responsibility. |
| [Aider](https://aider.chat/docs/install.html) | `aider` | Provider-flexible pair programming with strong Git integration | Not placed in the Brewfile. Aider recommends an isolated Python environment because system package managers can produce dependency conflicts. Install it with the already included `uv`. |

Homebrew-managed choices are commented in `Brewfile.apps.example`:

```ruby
cask "claude-code"
cask "codex"
cask "copilot-cli"
cask "antigravity-cli"
cask "cursor-cli"
brew "opencode"
```

For Aider, use its documented isolated installation path:

```bash
uv tool install --force --python python3.12 --with pip aider-chat@latest
```

Remove it with:

```bash
uv tool uninstall aider-chat
```

## Install a reviewed selection

Copy the example once, uncomment the editor and agent choices, and inspect the result:

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
cat Brewfile.apps
./scripts/bootstrap.sh --apps Brewfile.apps
```

The example intentionally contains competing choices. It is not intended to be installed unchanged.

## Choose the update owner deliberately

A reproducible Brewfile and the vendor's preferred installer solve different problems:

- **Homebrew ownership** keeps selected packages visible in one reviewed file and upgrades them through `brew upgrade`.
- **Vendor ownership** may receive releases sooner and may support background updates or release-channel controls.
- **Project ownership** is appropriate when a tool is pinned by the project rather than by the Mac.

Do not install the same command through multiple owners. Conflicting copies in `~/.local/bin`, Homebrew's prefix, npm global directories, or Python tool environments make updates and incident response harder to reason about.

Claude Code is the clearest example: its native installer is the vendor-recommended, auto-updating route, while Homebrew's `claude-code` cask follows a delayed stable channel and must be upgraded through Homebrew. Choose one route rather than both.

Cursor CLI similarly offers a vendor installer that attempts to auto-update and a Homebrew cask for Brewfile ownership. OpenCode recommends its own tap for the newest builds, but this public repository avoids adding third-party taps to the example and offers the potentially slower Homebrew core formula instead.

## Before the first agent session

1. Read the repository's `AGENTS.md`, `CLAUDE.md`, `.cursor/rules`, or equivalent instructions before trusting them; agents may load these files automatically.
2. Check `git status` and create a branch or worktree that can be discarded.
3. Begin with planning or read-only behavior when the tool supports it.
4. Read every proposed command before approving it, especially package installation, network access, deletion, database, cloud, and deployment commands.
5. Review the diff and run the project's tests yourself before committing or pushing.
6. Treat non-interactive, unattended, or full-auto modes as a separate security decision.
7. Review any MCP server as executable third-party integration code with access defined by the client configuration.
8. Store API keys in an appropriate credential or secret workflow, not in this public repository or a committed shell file.

## Current naming and migration notes

- Homebrew's `gemini-cli` formula is deprecated and currently recommends `antigravity-cli` as its replacement. New setups should not add `gemini-cli` merely because older guides mention it.
- `claude` is the Claude desktop application cask; `claude-code` installs the terminal coding agent whose command is also `claude`.
- `cursor` installs the editor and a `cursor` launcher; `cursor-cli` installs the separate `cursor-agent` command.
- `copilot-cli` is GitHub's AI coding CLI. The unrelated Homebrew formula named `copilot` is an AWS deployment tool.

## What this repository will not automate

This repository does not:

- sign in to an AI provider;
- store API keys, tokens, or subscription credentials;
- enable unattended or full-auto execution;
- grant an agent access to private repositories or cloud accounts;
- install MCP servers, plugins, hooks, skills, extensions, or custom agents;
- choose a model, billing plan, telemetry preference, or data-retention policy;
- install every editor and agent in the example.

Return to [Applications and Preferences](05-apps-and-preferences.md) or continue with [Maintenance](06-maintenance.md).
