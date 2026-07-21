# Tool and Application Catalog

**Reviewed:** July 21, 2026

This is a menu of credible options, not a recommendation to install everything.
The default setup remains intentionally small. Add a tool only when it owns a
recurring responsibility on the Mac.

Every listed package was checked against its current vendor documentation and
Homebrew entry at the review date. Availability, licensing, system requirements,
and product direction can change; run `brew info NAME` and open the linked pages
again before installing.

## How to use the catalog

Classifications used here:

- **Built-in**: already supplied by macOS; install nothing unless it is inadequate.
- **Baseline**: broadly required by the repository's intended developer workflow.
- **General**: useful across many projects, but still optional.
- **Specialized**: valuable for a named workflow rather than every developer.
- **Advanced**: needs meaningful configuration, permissions, or operational care.
- **Emerging**: useful and current, but comparatively young or fast-changing.

Before choosing an option, ask:

1. What repeated problem does it solve?
2. Is the macOS built-in tool already sufficient?
3. Does another selected tool already own the same responsibility?
4. What files, repositories, credentials, network traffic, or cloud data can it access?
5. What permissions, background items, extensions, subscriptions, or licenses does it need?
6. Who updates it: macOS, Homebrew, an in-app updater, an App Store account, or a project manager?
7. How will its settings and data be backed up, migrated, and removed?

For graphical applications:

```bash
cp Brewfile.apps.example Brewfile.apps
${EDITOR:-nano} Brewfile.apps
brew bundle check --file=Brewfile.apps --no-upgrade
brew bundle install --file=Brewfile.apps --no-upgrade
```

For optional formulae, agents, and role-specific developer tools:

```bash
cp Brewfile.extras.example Brewfile.local
${EDITOR:-nano} Brewfile.local
brew bundle check --file=Brewfile.local --no-upgrade
brew bundle install --file=Brewfile.local --no-upgrade
```

Both destination files are ignored by Git. Review every uncommented declaration
before applying it.

## Why the baseline is still small

| Tool | Classification | Responsibility | Why it is present |
| --- | --- | --- | --- |
| [Git](https://git-scm.com/docs/git) | Baseline | Version control | Most development workflows and this repository depend on Git. |
| [GitHub CLI](https://cli.github.com/manual/) | Baseline | GitHub authentication and operations | Provides a supported terminal path for repositories, issues, pull requests, and releases. |
| [mise](https://mise.jdx.dev/) | Baseline | Project-pinned non-Python runtimes and tools | Avoids installing a separate global manager for every language. |
| [uv](https://docs.astral.sh/uv/) | Baseline | Python versions, environments, dependencies, and tools | Keeps Python project state away from the system Python and global `pip`. |

The baseline does not claim these are the only good tools. It gives one owner to
each foundational responsibility and leaves editors, browsers, terminals,
containers, databases, cloud CLIs, and AI agents as explicit choices.

## Command-line navigation, search, and data

The current `Brewfile.cli` installs the first group. The remaining entries are
options for `Brewfile.local`.

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [bat](https://github.com/sharkdp/bat#readme) | `brew "bat"` | General | You frequently inspect source and text files in the terminal. | Adds highlighting, paging, line numbers, and Git context; it does not replace editing. |
| [fd](https://github.com/sharkdp/fd#readme) | `brew "fd"` | General | You want a simpler interactive file finder than many `find` invocations. | Respects ignore files by default, which can hide files that `find` would show. |
| [fzf](https://github.com/junegunn/fzf#readme) | `brew "fzf"` | General | You want fuzzy selection for files, history, branches, or custom pipelines. | It becomes most useful after deliberate shell integration. |
| [jq](https://jqlang.org/manual/) | `brew "jq"` | General | You inspect or transform JSON from APIs and tools. | Filters are a small language worth learning rather than copying blindly. |
| [ripgrep](https://github.com/BurntSushi/ripgrep#readme) | `brew "ripgrep"` | General | You search source trees frequently. | The package is `ripgrep`; the executable is `rg`. Ignore rules apply by default. |
| [tree](https://formulae.brew.sh/formula/tree) | `brew "tree"` | General | You want a quick directory hierarchy for orientation or documentation. | Large trees are noisy; use depth and ignore options. |
| [yq](https://mikefarah.gitbook.io/yq/) | `brew "yq"` | Specialized | YAML is common in your infrastructure or CI work. | Confirm which `yq` implementation a team expects; similarly named projects have existed. |
| [eza](https://eza.rocks/) | `brew "eza"` | General | You want richer directory listings and Git-aware metadata. | Keep `ls` knowledge for remote and minimal systems. |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `brew "zoxide"` | General | You repeatedly jump among a stable set of directories. | Requires shell initialization and learns from navigation history. |
| [delta](https://dandavison.github.io/delta/) | `brew "git-delta"` | General | You want readable syntax-highlighted Git diffs. | Requires Git pager configuration; preserve a straightforward rollback. |

## Shell, sessions, and repeatable commands

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [direnv](https://direnv.net/) | `brew "direnv"` | Advanced | A directory should load reviewed environment variables automatically. | `.envrc` executes code and must be reviewed before `direnv allow`. Do not commit secrets. |
| [Atuin](https://atuin.sh/) | `brew "atuin"` | Specialized | Searchable structured shell history would save substantial time. | Decide whether history remains local or is synchronized; history can contain sensitive commands. |
| [Starship](https://starship.rs/) | `brew "starship"` | General | You want one configurable prompt across shells. | Prompt initialization and modules add another configuration surface. |
| [tmux](https://github.com/tmux/tmux/wiki) | `brew "tmux"` | Advanced | Sessions must survive terminal windows, remote connections, or long-running work. | Has its own key model and configuration; terminal-native panes may be enough. |
| [lazygit](https://github.com/jesseduffield/lazygit) | `brew "lazygit"` | Specialized | You prefer a terminal UI for staging, history, rebases, and branches. | Understand the Git operations it triggers rather than treating the UI as a safety boundary. |
| [just](https://just.systems/) | `brew "just"` | Specialized | A project needs a discoverable command runner without using a Makefile as a general task language. | The project should commit its `justfile`; do not hide required commands in a machine-only file. |
| [watchexec](https://watchexec.github.io/) | `brew "watchexec"` | Specialized | Commands should rerun when project files change. | Watch scope and generated files can cause loops or excessive work. |

## Terminal diagnostics and benchmarking

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [btop](https://github.com/aristocratos/btop) | `brew "btop"` | General | You want an interactive process and resource monitor. | Activity views are diagnostic signals, not automatic evidence of a problem. |
| [dust](https://github.com/bootandy/dust) | `brew "dust"` | General | You need a quick visual explanation of disk use from the terminal. | Scanning large or protected trees can be slow and permission-sensitive. |
| [duf](https://github.com/muesli/duf) | `brew "duf"` | General | You want a clearer overview of mounted filesystems and free space. | It complements rather than replaces understanding `df`. |
| [hyperfine](https://github.com/sharkdp/hyperfine) | `brew "hyperfine"` | Specialized | You compare command performance with warmups and repeated runs. | Benchmarks need controlled inputs and interpretation; faster is not automatically better. |
| [tealdeer](https://tealdeer-rs.github.io/tealdeer/) | `brew "tealdeer"` | General | Concise command examples help more than a full manual page. | Community examples are a convenience, not authoritative documentation. |

## HTTP, APIs, and local services

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [xh](https://github.com/ducaale/xh) | `brew "xh"` | General | You want a concise command-line HTTP client with HTTPie-like syntax. | Keep `curl` knowledge because it is ubiquitous and built into macOS. |
| [HTTPie CLI](https://httpie.io/docs/cli) | `brew "httpie"` | General | Readable request syntax and formatted responses matter. | Authentication headers and request history can contain secrets. |
| [Bruno](https://www.usebruno.com/) | `cask "bruno"` | Specialized | API collections should live as files that fit a Git workflow. | Review environment and secret handling before committing collections. |
| [Postman](https://learning.postman.com/docs/introduction/overview/) | `cask "postman"` | Specialized | A team already uses Postman collections, workspaces, mocks, or collaboration. | Review cloud synchronization, account requirements, and workspace visibility. |
| [Insomnia](https://developer.konghq.com/insomnia/) | `cask "insomnia"` | Specialized | You need a graphical HTTP and GraphQL client. | Review synchronization and authentication storage choices. |
| [Yaak](https://yaak.app/) | `cask "yaak"` | Specialized | One client should cover REST, GraphQL, and gRPC. | Newer workflow choices deserve a small trial before standardization. |

## Browsers

Safari is already installed. Add another browser for a concrete reason such as
Chromium compatibility, Firefox testing, Google or Microsoft account integration,
profile separation, extension requirements, or privacy preferences.

| Browser | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [Safari](https://support.apple.com/guide/safari/welcome/mac) | Built-in | Built-in | You want the platform browser and no additional installation. | Web developers still need other engines for compatibility testing. |
| [Google Chrome](https://www.google.com/chrome/) | `cask "google-chrome"` | General | Chromium compatibility, Chrome extensions, DevTools, or Google Workspace integration is required. | Review account sync, profiles, background behavior, and organizational policy. |
| [Firefox](https://support.mozilla.org/products/firefox) | `cask "firefox"` | General | You want Firefox's engine, profiles, extensions, or cross-browser testing. | Extension and sync choices remain part of the setup. |
| [Brave](https://support.brave.com/) | `cask "brave-browser"` | Specialized | You want a Chromium browser with privacy-focused defaults. | Review site compatibility, rewards-related features, and organization policy. |
| [Microsoft Edge](https://www.microsoft.com/edge) | `cask "microsoft-edge"` | Specialized | Microsoft 365, Entra-managed work, Edge profiles, or Edge-specific testing matters. | Work management and account policy may own installation. |
| [Vivaldi](https://help.vivaldi.com/) | `cask "vivaldi"` | Specialized | Deep browser customization and built-in productivity features are important. | A large feature surface creates more configuration to migrate. |
| [Orion](https://help.kagi.com/orion/) | `cask "orion"` | Specialized | You want a WebKit-based alternative with a Mac-focused product direction. | Test required sites and extensions before making it the only browser. |
| [Arc](https://resources.arc.net/) | `cask "arc"` | Specialized | Arc's workspace and tab model fits your workflow. | Product direction and account behavior should be rechecked before standardizing. |
| [DuckDuckGo](https://duckduckgo.com/duckduckgo-help-pages/desktop/) | `cask "duckduckgo"` | Specialized | You want a privacy-focused desktop browser with a simpler feature set. | Validate extension and developer-tool requirements. |

Do not install every browser automatically. A practical web-development setup is
often Safari plus Chrome and Firefox, while a non-web workflow may need only one.

## Terminals and agent workspaces

Terminal.app is sufficient to clone and bootstrap the repository. Choose one
alternative when it solves a specific rendering, multiplexing, automation,
remote-access, or multi-agent problem.

| Terminal or workspace | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| Terminal.app | Built-in | Built-in | You need a dependable terminal with no additional installation. | Fewer advanced panes, workspace, and automation features than some alternatives. |
| [Ghostty](https://ghostty.org/docs) | `cask "ghostty"` | General | A fast terminal with native macOS UI is the goal. | Configuration and feature expectations differ from long-established terminals. |
| [iTerm2](https://iterm2.com/documentation.html) | `cask "iterm2"` | General | Mature profiles, panes, triggers, automation, and extensive settings are useful. | Its breadth can produce substantial configuration and plugin state. |
| [cmux](https://www.cmux.dev/) | `cask "cmux"` | Emerging | You run multiple coding agents and want vertical workspaces, notifications, splits, and an integrated browser. | It overlaps with terminals, multiplexers, and agent managers and currently requires macOS 14 or newer. |
| [Warp](https://docs.warp.dev/) | `cask "warp"` | Specialized | A block-oriented terminal and integrated collaborative or AI workflow appeals. | Review account, cloud, telemetry, and team-policy implications. |
| [WezTerm](https://wezterm.org/config/files.html) | `cask "wezterm"` | Advanced | Cross-platform configuration and built-in multiplexing are priorities. | Lua configuration is powerful but becomes another maintained codebase. |
| [kitty](https://sw.kovidgoyal.net/kitty/) | `cask "kitty"` | Advanced | Keyboard-driven terminal features and a scriptable remote-control model fit your workflow. | Learn its configuration and compatibility choices before standardizing. |
| [Tabby](https://tabby.sh/) | `cask "tabby"` | Specialized | One application should cover local terminals, SSH, and serial connections. | Its cross-platform application layer is heavier than a minimal native terminal. |

The Homebrew cask for Alacritty is marked deprecated at this review date, so it
is intentionally absent from the copy-paste template. That is packaging status,
not a universal judgment about the upstream project; recheck before adding it.

## Editors and IDEs

Choose one primary editor or IDE first. Secondary editors are useful only for a
specific workflow such as native Apple development, Android, JetBrains projects,
or quick plain-text work.

| Editor or IDE | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [Visual Studio Code](https://code.visualstudio.com/docs) | `cask "visual-studio-code"` | General | You want a broad language and extension ecosystem with team familiarity. | Extensions execute code and can access repositories; review and minimize them. |
| [Cursor](https://docs.cursor.com/) | `cask "cursor"` | Specialized | AI-assisted editing is central and its model/provider workflow fits. | Review source-code handling, indexing, account, billing, and organization policy. |
| [Zed](https://zed.dev/docs) | `cask "zed"` | Emerging | A fast collaborative editor and modern native workflow appeals. | Confirm language, extension, remote, and team requirements before replacing an established IDE. |
| [Windsurf](https://docs.windsurf.com/) | `cask "windsurf"` | Specialized | An AI-centered editor workflow is preferred. | Apply the same code-access, account, model, billing, and policy review as other AI editors. |
| [Sublime Text](https://www.sublimetext.com/docs/) | `cask "sublime-text"` | General | Fast editing, large files, and a focused text-editor model matter. | Some workflows require a paid license and package configuration. |
| [Nova](https://help.nova.app/) | `cask "nova"` | Specialized | A native Mac editor and Panic's workflow fit your projects. | Validate language tooling and team interoperability. |
| [BBEdit](https://www.barebones.com/support/bbedit/) | `cask "bbedit"` | Specialized | Native text, code, markup, transformations, and large-file work are priorities. | It has a distinct workflow from extension-heavy IDEs. |
| [JetBrains Toolbox](https://www.jetbrains.com/help/toolbox-app/) | `cask "jetbrains-toolbox"` | Specialized | You use IntelliJ IDEA, WebStorm, PyCharm, GoLand, DataGrip, or multiple JetBrains products. | Licensing, disk use, JVMs, and per-IDE updates need ownership. |
| [Android Studio](https://developer.android.com/studio/intro) | `cask "android-studio"` | Specialized | You build Android applications. | SDKs, emulators, Java versions, and large caches require separate planning. |
| [Xcode](https://developer.apple.com/xcode/) | App Store or Apple Developer downloads | Specialized | You build or sign software for Apple platforms. | Xcode is large, version-sensitive, and separate from the small Command Line Tools installation. |
| [Neovim](https://neovim.io/doc/) | `brew "neovim"` | Advanced | A keyboard-first, terminal-based, programmable editor is worth maintaining. | Configuration and plugins can become a personal software distribution. |
| [Helix](https://docs.helix-editor.com/) | `brew "helix"` | Advanced | A modal terminal editor with built-in modern language features fits. | Its editing model differs from Vim and mainstream graphical editors. |

## AI coding agents and orchestration

AI tools can read repositories, execute commands, modify files, call networks,
and consume paid services. Treat each one as a privileged development tool, not
as a harmless shell convenience. Start with one agent, learn its permission and
sandbox model, and keep secrets out of prompts and logs.

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) | `cask "claude-code"` | Specialized | Anthropic's terminal agent fits your repositories and account model. | Review command approval, code/data handling, billing, and organization policy. |
| [OpenAI Codex CLI](https://github.com/openai/codex) | `cask "codex"` | Specialized | OpenAI's terminal coding agent fits your workflow. | Review sandboxing, approvals, repository access, network use, and billing. |
| [OpenCode](https://opencode.ai/docs/) | `brew "opencode"` | Specialized | You want a terminal agent with provider flexibility and an open-source core. | Provider configuration and credentials still need secure ownership. |
| [Aider](https://aider.chat/docs/) | `brew "aider"` | Specialized | Git-aware terminal pair programming across supported model providers is useful. | Its Homebrew dependency footprint is larger; review model costs and Git behavior. |
| [Claude Squad](https://smtg-ai.github.io/claude-squad/) | `brew "claude-squad"` | Advanced | You deliberately coordinate several terminal agents. | Parallel agents amplify cost, conflicts, context leakage, and review burden. |
| [Conductor](https://conductor.build/) | `cask "conductor"` | Emerging | You want a graphical workflow for parallel Claude Code work. | Evaluate worktree behavior, product maturity, account requirements, and conflict handling. |
| [cmux](https://www.cmux.dev/) | `cask "cmux"` | Emerging | Terminal workspaces and visible agent activity should live together. | It is a workspace, not a model provider; avoid duplicating orchestration layers. |
| [OpenUsage](https://www.openusage.ai/) | `cask "openusage"` | Emerging | You need a local overview of usage across several AI coding tools. | Usage logs can reveal project and account metadata; inspect its data sources and retention. |

Homebrew currently marks the `gemini-cli` formula deprecated with a replacement
recommendation. It is therefore not in the example Brewfiles. Recheck the vendor
and Homebrew status rather than copying an older install line.

## Containers and virtual machines

Choose one primary local container owner. Running several desktop engines at the
same time creates duplicate VMs, sockets, networks, caches, and background work.

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [Docker Desktop](https://docs.docker.com/desktop/setup/install/mac-install/) | `cask "docker-desktop"` | Specialized | A team standardizes on Docker Desktop, its integrations, or its support model. | Review current licensing, resource use, privileged helpers, extensions, and organization policy. |
| [OrbStack](https://docs.orbstack.dev/) | `cask "orbstack"` | Specialized | A Mac-focused Docker and Linux-machine workflow fits the team. | Commercial terms, team compatibility, and migration from Docker Desktop should be reviewed. |
| [Podman Desktop](https://podman-desktop.io/docs/installation/macos-install) | `cask "podman-desktop"` | Specialized | Podman and daemonless/container-engine workflows are preferred. | Local containers still require a Linux virtual machine on macOS. |
| [Rancher Desktop](https://docs.rancherdesktop.io/) | `cask "rancher"` | Specialized | Desktop Kubernetes and container-engine choices are both needed. | It conflicts with Docker Desktop's cask and adds a substantial local cluster surface. |
| [Colima](https://colima.run/) | `brew "colima"` | Advanced | You prefer a command-line-managed container VM with minimal desktop UI. | Pair it with a reviewed client/Compose setup and own VM lifecycle explicitly. |
| [UTM](https://docs.getutm.app/) | `cask "utm"` | Specialized | You need general virtual machines through a native QEMU-based interface. | Guest architecture, disk images, networking, and backup sizes require planning. |
| [Parallels Desktop](https://docs.parallels.com/) | `cask "parallels"` | Specialized | Polished commercial desktop virtualization and supported guest workflows are worth the license. | Check current licensing, guest support, resource allocation, and organization policy. |
| [VMware Fusion](https://techdocs.broadcom.com/us/en/vmware-cis/desktop-hypervisors/fusion-pro.html) | `cask "vmware-fusion"` | Specialized | Existing VMware-compatible VMs or team practices require it. | Recheck current account, licensing, download, and support requirements. |

## Database clients

A database GUI is not part of the baseline. Prefer a client that supports the
actual databases, authentication methods, SSH/tunnel workflow, and team policy.
Never place production credentials in a public Brewfile or repository.

| Client | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [TablePlus](https://docs.tableplus.com/) | `cask "tableplus"` | Specialized | A native multi-database client and focused interface fit. | Check free versus paid limits and secure credential storage. |
| [DBeaver Community](https://dbeaver.com/docs/dbeaver/) | `cask "dbeaver-community"` | Specialized | Broad database and JDBC coverage matters. | Java-based breadth can mean a heavier interface and driver management. |
| [Beekeeper Studio](https://docs.beekeeperstudio.io/) | `cask "beekeeper-studio"` | Specialized | A cross-platform SQL editor with an approachable interface fits. | Check edition differences and supported database features. |
| [DataGrip](https://www.jetbrains.com/help/datagrip/) | `cask "datagrip"` | Specialized | JetBrains database tooling, inspections, and IDE integration are valuable. | Requires a JetBrains license unless covered by an existing plan. |
| [Postico](https://eggerapps.at/postico2/documentation.html) | `cask "postico"` | Specialized | A native PostgreSQL-focused client is sufficient. | PostgreSQL focus is a strength only when other engines are not needed. |
| [Sequel Ace](https://sequel-ace.com/) | `cask "sequel-ace"` | Specialized | You need a focused MySQL or MariaDB client. | It is not a general multi-database replacement. |
| [DB Browser for SQLite](https://sqlitebrowser.org/docs/) | `cask "db-browser-for-sqlite"` | Specialized | You inspect or edit local SQLite databases. | Treat edits to application databases as potentially destructive. |
| [MongoDB Compass](https://www.mongodb.com/docs/compass/) | `cask "mongodb-compass"` | Specialized | MongoDB-specific browsing, queries, and schema exploration are required. | Review telemetry, connection-string handling, and production access policy. |
| [Redis Insight](https://redis.io/docs/latest/develop/tools/insight/) | `cask "redis-insight"` | Specialized | Redis data, metrics, and command workflows need a GUI. | Production keys and destructive commands deserve explicit safeguards. |
| [DbGate](https://docs.dbgate.org/) | `cask "dbgate"` | Specialized | One open-source client should cover SQL and selected NoSQL systems. | Validate engine-specific depth before standardizing. |

## Git graphical clients

The Git CLI remains the common denominator. A graphical client can improve
visual history, conflict resolution, or branch workflows, but it should not hide
what operation will be performed.

| Client | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [GitHub Desktop](https://docs.github.com/en/desktop) | `cask "github"` | General | A simple GitHub-oriented commit, branch, and pull-request workflow is enough. | Less suitable for every advanced Git operation or non-GitHub hosting workflow. |
| [Fork](https://git-fork.com/help) | `cask "fork"` | Specialized | You want a focused graphical Git client with detailed history and operations. | Check licensing and understand advanced actions before confirming them. |
| [Tower](https://www.git-tower.com/help/) | `cask "tower"` | Specialized | A polished commercial Git workflow and support are valuable. | Requires a current license or subscription arrangement. |
| [Sublime Merge](https://www.sublimemerge.com/docs/) | `cask "sublime-merge"` | Specialized | Fast graphical history, staging, and merge work fit the Sublime model. | Check licensing and integration preferences. |
| [GitKraken](https://help.gitkraken.com/gitkraken-desktop/gitkraken-desktop-home/) | `cask "gitkraken"` | Specialized | Visual branch topology and GitKraken's collaboration ecosystem fit. | Account, licensing, cloud features, and private-repository policy need review. |
| [GitButler](https://docs.gitbutler.com/) | `cask "gitbutler"` | Emerging | Simultaneous virtual branches solve a concrete workflow problem. | Its branch model differs from ordinary Git clients; test it on noncritical work first. |
| [lazygit](https://github.com/jesseduffield/lazygit) | `brew "lazygit"` | Specialized | You want a keyboard-driven terminal UI rather than a desktop application. | It is still executing Git operations against the repository. |

## Window management, launchers, and automation

macOS includes window tiling, Spotlight, Shortcuts, Automator, and keyboard
shortcuts. Third-party tools are optional enhancements and often request
Accessibility, Screen Recording, or Input Monitoring access.

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [macOS window tiling](https://support.apple.com/guide/mac-help/tile-windows-mchlef287e5d/mac) | Built-in | Built-in | Standard halves, quarters, fill, and keyboard tiling are enough. | Review tiling and margin settings before adding another window manager. |
| [Rectangle](https://rectangleapp.com/) | `cask "rectangle"` | General | Straightforward keyboard window movement and resize shortcuts are enough. | Requires Accessibility permission. Avoid conflicting shortcuts with macOS tiling. |
| [Loop](https://github.com/MrKai77/Loop) | `cask "loop"` | Emerging | Visual radial window controls and custom layouts fit. | Requires meaningful permissions and overlaps with built-in tiling and Rectangle. |
| [Moom](https://manytricks.com/moom/help/) | `cask "moom"` | Specialized | Saved layouts and a mature commercial window workflow are useful. | Check license and permission requirements. |
| [AeroSpace](https://nikitabobko.github.io/AeroSpace/guide) | `cask "aerospace"` | Advanced | A keyboard-first tiling window manager is worth configuring. | Changes the window-management model and demands maintained configuration. |
| [yabai](https://github.com/koekeishiya/yabai/wiki) | `brew "yabai"` | Advanced | Highly scriptable tiling and automation justify deeper system knowledge. | Some capabilities have additional security tradeoffs; read upstream documentation before enabling them. |
| [Raycast](https://manual.raycast.com/) | `cask "raycast"` | General | Launcher, snippets, clipboard, quick links, and extensions should live in one app. | Extensions and cloud/account features expand the trust surface. |
| [Alfred](https://www.alfredapp.com/help/) | `cask "alfred"` | General | A mature launcher with local workflows and optional Powerpack features fits. | Advanced workflows can execute arbitrary scripts; back them up and review them. |
| [Hammerspoon](https://www.hammerspoon.org/go/) | `cask "hammerspoon"` | Advanced | You want code-driven macOS automation in Lua. | Accessibility permissions plus arbitrary automation make configuration security-sensitive. |
| [BetterTouchTool](https://docs.folivora.ai/) | `cask "bettertouchtool"` | Advanced | Input devices, gestures, window actions, and automation need one configurable owner. | Broad permissions and complex rules deserve backups, review, and conflict avoidance. |

## Mouse, trackpad, keyboard, and display enhancements

Start with the supported settings in [macOS ergonomics](macos-ergonomics.md).
Install an enhancement only when built-in tracking speed, pointer acceleration,
scrolling, buttons, gestures, remapping, or display controls are insufficient.

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [LinearMouse](https://linearmouse.app/) | `cask "linearmouse"` | Specialized | Per-device pointer acceleration, speed, scrolling, or button behavior is needed. | It overlaps with current built-in acceleration settings; use it for requirements macOS does not satisfy. |
| [Mos](https://mos.caldis.me/) | `cask "mos"` | Specialized | Smooth scrolling or separate mouse-versus-trackpad scroll direction is the main need. | Input tools can conflict; choose one owner for scrolling. |
| [SteerMouse](https://plentycom.jp/en/steermouse/) | `cask "steermouse"` | Specialized | Third-party mouse buttons, wheels, chords, and cursor behavior need deep configuration. | Commercial licensing and broad input permissions require review. |
| [BetterMouse](https://better-mouse.com/) | `cask "bettermouse"` | Specialized | A third-party mouse needs Mac-specific acceleration, scrolling, and button features. | Avoid running it alongside another mouse remapper. |
| [Karabiner-Elements](https://karabiner-elements.pqrs.org/docs/) | `cask "karabiner-elements"` | Advanced | Low-level keyboard remapping solves a concrete layout or hardware problem. | Requires significant input permissions and careful rule review. |
| [BetterDisplay](https://github.com/waydabber/BetterDisplay/wiki) | `cask "betterdisplay"` | Advanced | External-display scaling, virtual displays, brightness, or display overrides are required. | Display overrides can be confusing to recover; document each change. |
| [Lunar](https://lunar.fyi/docs) | `cask "lunar"` | Specialized | External-display brightness and adaptive control are the primary needs. | Hardware compatibility varies; test before relying on it. |

## Passwords, networking, and security utilities

Apple's Passwords app, FileVault, firewall, VPN support, Gatekeeper, and platform
security are already present. Add a tool only as part of an explicit security or
team-access model.

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [Apple Passwords](https://support.apple.com/guide/passwords/welcome/mac) | Built-in | Built-in | Apple-platform credential and passkey synchronization meets your needs. | Cross-platform, sharing, business administration, and recovery needs may require another manager. |
| [1Password](https://support.1password.com/) | `cask "1password"` | Specialized | Cross-platform vaults, passkeys, sharing, developer integrations, or business administration fit. | Recovery, subscription, browser extension, CLI, and organization ownership must be planned. |
| [Bitwarden](https://bitwarden.com/help/) | `cask "bitwarden"` | Specialized | Bitwarden's cross-platform and deployment model fits. | Choose hosted or self-hosted ownership deliberately and secure recovery material. |
| [KeePassXC](https://keepassxc.org/docs/) | `cask "keepassxc"` | Advanced | You want a local database file and control its synchronization yourself. | Backup, synchronization conflicts, key files, and recovery are entirely your responsibility. |
| [Tailscale](https://tailscale.com/kb/) | `cask "tailscale"` | Specialized | Identity-aware mesh networking solves remote access or private service connectivity. | Network extensions, account ownership, device approval, ACLs, and exit nodes need governance. |
| [WireGuard](https://www.wireguard.com/quickstart/) | `cask "wireguard"` | Advanced | A WireGuard configuration is already supplied by a trusted network owner. | Key distribution, routes, DNS, and endpoint ownership are operational responsibilities. |
| [LuLu](https://objective-see.org/products/lulu.html) | `cask "lulu"` | Advanced | You want prompts and rules for unknown outbound connections. | Rule noise and blocked update/auth flows require informed decisions. |
| [Little Snitch](https://help.obdev.at/littlesnitch6/) | `cask "little-snitch"` | Advanced | A mature commercial outbound network monitor and rule system is worth managing. | Requires system/network permissions, rule maintenance, and a license. |

## System visibility, cleanup, and storage

Avoid applications that promise vague automatic “speedups.” Prefer tools that
show understandable state or remove one reviewed application at a time.

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [Stats](https://github.com/exelban/stats) | `cask "stats"` | General | Open-source menu-bar CPU, memory, disk, network, sensor, or battery visibility is useful. | Constant metrics can create noise; enable only modules you use. |
| [iStat Menus](https://bjango.com/mac/istatmenus/) | `cask "istat-menus"` | Specialized | A polished commercial system monitor and history are worth the license. | Sensor access, background activity, and alert settings need review. |
| [Maccy](https://maccy.app/) | `cask "maccy"` | General | A lightweight clipboard history solves a recurring need. | Clipboard history can retain passwords and sensitive data; configure exclusions and retention. |
| [AppCleaner](https://freemacsoft.net/appcleaner/) | `cask "appcleaner"` | Specialized | You want to review related files while removing an app. | Never treat every suggested file as safe to delete without inspection. |
| [Pearcleaner](https://itsalin.com/appInfo/?id=pearcleaner) | `cask "pearcleaner"` | Emerging | An open-source app uninstaller and leftover-file review fit. | The same deletion caution applies; do not run multiple cleanup tools automatically. |
| [GrandPerspective](https://grandperspectiv.sourceforge.net/) | `cask "grandperspective"` | General | A visual map helps explain disk usage. | Full-disk scans may require permissions and can expose sensitive filenames onscreen. |

## Notes, communication, and file transfer

These normally belong in a personal or work-specific overlay rather than a public
developer baseline.

| Tool | Homebrew declaration | Classification | Best when | Considerations |
| --- | --- | --- | --- | --- |
| [Obsidian](https://help.obsidian.md/) | `cask "obsidian"` | Specialized | A local Markdown knowledge base and plugin ecosystem fit. | Plugins execute code; synchronization and encryption choices need review. |
| [Notion](https://www.notion.com/help) | `cask "notion"` | Specialized | A team already uses Notion for collaborative docs and planning. | Workspace ownership, offline expectations, exports, and data residency matter. |
| [Slack](https://slack.com/help) | `cask "slack"` | Work-specific | An organization requires Slack. | Workspace retention, notifications, downloads, and login items are organizational choices. |
| [Zoom](https://support.zoom.com/) | `cask "zoom"` | Work-specific | Meetings or support workflows require Zoom. | Review microphone, camera, screen-recording, background, and update permissions. |
| [Microsoft Teams](https://support.microsoft.com/teams) | `cask "microsoft-teams"` | Work-specific | Microsoft 365 collaboration is an organizational requirement. | Account management, notifications, screen sharing, and background activity need review. |
| [Discord](https://support.discord.com/) | `cask "discord"` | Specialized | Communities or teams use Discord. | Treat downloads, links, servers, bots, and account security carefully. |
| [Cyberduck](https://docs.cyberduck.io/) | `cask "cyberduck"` | Specialized | Graphical SFTP and cloud-object transfers are needed. | Protect bookmarks, credentials, private keys, and downloaded data. |
| [Transmit](https://library.panic.com/transmit/) | `cask "transmit"` | Specialized | A polished commercial Mac file-transfer client is worth the license. | Server credentials and synchronization actions can be destructive. |
| [ForkLift](https://binarynights.com/manual) | `cask "forklift"` | Specialized | Dual-pane file management plus remote connections fits. | File operations, sync jobs, and credentials need deliberate review. |

## Fonts

A font is optional and should not be required to understand shell output. Nerd
Fonts are useful when a chosen prompt or terminal UI uses their extra glyphs.

| Font | Homebrew declaration | Best when | Considerations |
| --- | --- | --- | --- |
| [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads) | `cask "font-jetbrains-mono-nerd-font"` | You want a readable coding font plus terminal glyphs. | Select it separately in the terminal or editor. |
| [Fira Code](https://github.com/tonsky/FiraCode) | `cask "font-fira-code"` | Programming ligatures are useful and supported by the editor. | Ligatures are taste and can obscure exact character sequences for some readers. |
| [Iosevka Nerd Font](https://typeof.net/Iosevka/) | `cask "font-iosevka-nerd-font"` | A compact highly configurable style plus terminal glyphs fits. | Its narrow design is not comfortable for everyone. |

## Role-based starting points

These are starting hypotheses, not bundles to install unchanged.

### Minimal general developer

- Baseline `Brewfile`.
- `ripgrep`, `fd`, `fzf`, `jq`, and `bat` only when used.
- Safari or one preferred browser.
- Terminal.app or one preferred terminal.
- One editor.

### Web application developer

- Safari, Chrome, and Firefox for engine coverage.
- One editor or IDE.
- One container engine only when projects require it.
- One API client and one database client matched to the stack.
- Project-owned Node and other runtimes through `mise`; Python through `uv`.

### AI-agent-heavy developer

- One terminal agent first: Claude Code, Codex, OpenCode, or Aider.
- cmux, tmux, Conductor, or Claude Squad only after a real parallel-work need appears.
- Explicit approval, sandbox, Git, billing, and secrets practices.
- Optional usage monitoring after reviewing what local metadata it reads.

### Apple-platform developer

- Xcode and its selected simulators.
- Keep Command Line Tools and Xcode selection explicit with `xcode-select`.
- Add Homebrew tools only when the project requires them.

### Android developer

- Android Studio.
- Project-owned Java and auxiliary tools where practical.
- Deliberate SDK, emulator, cache, and device configuration.

### Infrastructure and cloud developer

Consider project- or team-pinned versions of:

- [kubectl](https://kubernetes.io/docs/reference/kubectl/) — `brew "kubectl"`;
- [k9s](https://k9scli.io/) — `brew "k9s"`;
- [Helm](https://helm.sh/docs/) — `brew "helm"`;
- [OpenTofu](https://opentofu.org/docs/) — `brew "opentofu"`;
- [AWS CLI](https://docs.aws.amazon.com/cli/) — `brew "awscli"`;
- [Google Cloud CLI](https://cloud.google.com/sdk/docs) — `cask "gcloud-cli"`.

Cloud credentials, Kubernetes contexts, VPNs, certificates, and organization
configuration belong outside this public repository.

## Maintenance policy for this catalog

An option belongs here when it has:

- a clear recurring use case;
- a current official source and install path;
- a stated alternative or built-in baseline;
- documented trust, permission, licensing, or overlap considerations;
- no requirement that everyone install it.

Deprecation or disabling in Homebrew should remove an entry from example
Brewfiles promptly. The catalog may retain a short note when the status itself is
important. Inclusion means “worth evaluating for this use case,” not “best,”
“safe for every organization,” or “recommended without review.”
