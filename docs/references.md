# Primary References

These sources inform the repository's current behavior. Platform-sensitive instructions should prefer owner documentation over copied setup recipes.

**Reviewed:** July 21, 2026

## Apple

- [Apple security releases](https://support.apple.com/en-us/100100)
- [Installing the Command Line Tools](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [Volume encryption with FileVault](https://support.apple.com/guide/security/volume-encryption-with-filevault-sec4c6dc1b6e/web)
- [Protect data with FileVault](https://support.apple.com/guide/mac-help/protect-data-on-your-mac-with-filevault-mh11785/mac)
- [Background Security Improvements](https://support.apple.com/guide/mac-help/install-background-security-improvements-mchl44c4c70c/mac)
- [macOS firewall](https://support.apple.com/guide/mac-help/block-connections-to-your-mac-with-a-firewall-mh34041/mac)
- [Time Machine](https://support.apple.com/en-us/104984)

## Homebrew

- [Installation](https://docs.brew.sh/Installation)
- [Reviewed Homebrew installer commit](https://github.com/Homebrew/install/commit/99e13e96cbbdc1ac1ac09c0a40b450bf219ef3aa)
- [Homebrew Bundle command reference](https://docs.brew.sh/Manpage#bundle-subcommand)
- [Support tiers and native prefixes](https://docs.brew.sh/Support-Tiers)
- [Supply-chain security](https://docs.brew.sh/Supply-Chain-Security)
- [Tap trust](https://docs.brew.sh/Tap-Trust)
- [Formulae and cask catalog](https://formulae.brew.sh/)

## Git and GitHub

- [Git reference](https://git-scm.com/docs/git)
- [Install Git](https://github.com/git-guides/install-git)
- [GitHub CLI manual](https://cli.github.com/manual/)
- [`gh auth login`](https://cli.github.com/manual/gh_auth_login)
- [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Generating an SSH key and adding it to the agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

## Runtime and repository tools

- [mise documentation](https://mise.jdx.dev/)
- [Installing mise](https://mise.jdx.dev/installing-mise.html)
- [mise GitHub Action](https://github.com/jdx/mise-action)
- [uv documentation](https://docs.astral.sh/uv/)
- [Installing uv](https://docs.astral.sh/uv/getting-started/installation/)
- [uv tool environments](https://docs.astral.sh/uv/concepts/tools/)
- [Node.js releases](https://nodejs.org/en/about/previous-releases)
- [Ruby downloads](https://www.ruby-lang.org/en/downloads/)

## Optional command-line tools

- [bat](https://github.com/sharkdp/bat#readme)
- [fd](https://github.com/sharkdp/fd#readme)
- [fzf](https://github.com/junegunn/fzf#readme)
- [jq manual](https://jqlang.org/manual/)
- [ripgrep](https://github.com/BurntSushi/ripgrep#readme)
- [ShellCheck](https://www.shellcheck.net/)
- [shfmt](https://github.com/mvdan/sh#shfmt)
- [`tree`](https://formulae.brew.sh/formula/tree)

## Optional applications

- [1Password support](https://support.1password.com/)
- [Bitwarden help](https://bitwarden.com/help/)
- [Firefox support](https://support.mozilla.org/products/firefox)
- [Visual Studio Code documentation](https://code.visualstudio.com/docs)
- [Zed documentation](https://zed.dev/docs)
- [Ghostty documentation](https://ghostty.org/docs)
- [iTerm2 documentation](https://iterm2.com/documentation.html)
- [Docker Desktop for Mac](https://docs.docker.com/desktop/setup/install/mac-install/)
- [OrbStack documentation](https://docs.orbstack.dev/)
- [Podman Desktop for macOS](https://podman-desktop.io/docs/installation/macos-install)
- [Rectangle](https://github.com/rxhanson/Rectangle#readme)
- [Raycast manual](https://manual.raycast.com/)
- [chezmoi command overview](https://www.chezmoi.io/user-guide/command-overview/)
- [`mas`](https://github.com/mas-cli/mas#readme)

## Repository automation

- [GitHub-hosted runner reference](https://docs.github.com/actions/using-github-hosted-runners/about-github-hosted-runners)
- [Runner image catalog](https://github.com/actions/runner-images)
- [actions/checkout](https://github.com/actions/checkout)
- [Reviewed `actions/checkout` v7 commit](https://github.com/actions/checkout/commit/9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0)
- [Reviewed `jdx/mise-action` v4 commit](https://github.com/jdx/mise-action/commit/dad1bfd3df957f44999b559dd69dc1671cb4e9ea)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)

## Review policy

A reference appearing here does not make every upstream recommendation mandatory. The repository applies a narrower policy based on its threat model and design principles.

When upstream behavior changes, update the script, tests, and explanatory document together. Do not preserve an obsolete command only because it once appeared in a popular article.
