# Primary References

These sources informed the repository's current behavior. They are intentionally dominated by platform and tool owners rather than copied setup recipes.

**Reviewed:** July 22, 2026

## Apple

- [Apple security releases](https://support.apple.com/en-us/100100)
- [Volume encryption with FileVault in macOS](https://support.apple.com/guide/security/volume-encryption-with-filevault-sec4c6dc1b6e/web)
- [Protect data on your Mac with FileVault](https://support.apple.com/guide/mac-help/protect-data-on-your-mac-with-filevault-mh11785/mac)
- [Automatically install Background Security Improvements](https://support.apple.com/guide/mac-help/install-background-security-improvements-mchl44c4c70c/mac)
- [Block connections with the macOS firewall](https://support.apple.com/guide/mac-help/block-connections-to-your-mac-with-a-firewall-mh34041/mac)
- [Back up your Mac with Time Machine](https://support.apple.com/en-us/104984)
- [Show or hide filename extensions](https://support.apple.com/guide/mac-help/show-or-hide-filename-extensions-on-mac-mchlp2304/mac)
- [Change Finder settings](https://support.apple.com/guide/mac-help/change-finder-settings-mchlp2803/mac)
- [Show Finder status and path information](https://support.apple.com/guide/mac-help/get-file-folder-and-disk-information-mchlp1774/mac)
- [Take a screenshot](https://support.apple.com/en-us/102646)
- [Mac keyboard shortcuts](https://support.apple.com/guide/mac-help/intro-to-mac-keyboard-shortcuts-mchld6b9e240/mac)
- [Manage login items and background activity](https://support.apple.com/guide/mac-help/open-items-automatically-when-you-log-in-mh15189/mac)

## Homebrew

- [Installation](https://docs.brew.sh/Installation)
- [Reviewed Homebrew installer commit](https://github.com/Homebrew/install/commit/99e13e96cbbdc1ac1ac09c0a40b450bf219ef3aa)
- [Homebrew Bundle and Brewfile command reference](https://docs.brew.sh/Manpage#bundle-subcommand)
- [Support tiers](https://docs.brew.sh/Support-Tiers)
- [Homebrew security and supply chain](https://docs.brew.sh/Supply-Chain-Security)
- [Tap trust](https://docs.brew.sh/Tap-Trust)
- [Formulae and cask catalog](https://formulae.brew.sh/)

## Git and GitHub

- [Git reference](https://git-scm.com/docs/git)
- [Install Git](https://github.com/git-guides/install-git)
- [GitHub CLI manual](https://cli.github.com/manual/)
- [`gh auth login`](https://cli.github.com/manual/gh_auth_login)
- [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Generating a new SSH key and adding it to the agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

## Runtime tools

- [mise documentation](https://mise.jdx.dev/)
- [Installing mise](https://mise.jdx.dev/installing-mise.html)
- [uv documentation](https://docs.astral.sh/uv/)
- [Installing uv](https://docs.astral.sh/uv/getting-started/installation/)
- [uv tool environments](https://docs.astral.sh/uv/concepts/tools/)

## Optional command-line tools

- [bat](https://github.com/sharkdp/bat#readme)
- [fd](https://github.com/sharkdp/fd#readme)
- [fzf](https://github.com/junegunn/fzf#readme)
- [jq manual](https://jqlang.org/manual/)
- [ripgrep (`rg`)](https://github.com/BurntSushi/ripgrep#readme)
- [ShellCheck](https://www.shellcheck.net/)
- [shfmt](https://github.com/mvdan/sh#shfmt)
- [`tree` Homebrew formula](https://formulae.brew.sh/formula/tree)

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

- [actions/checkout](https://github.com/actions/checkout)
- [Reviewed `actions/checkout` v7 commit](https://github.com/actions/checkout/commit/9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0)
- [ShellCheck](https://www.shellcheck.net/)
- [shfmt](https://github.com/mvdan/sh)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)

## Review policy

A reference appearing here does not make every upstream recommendation mandatory. The repository applies a narrower policy based on its threat model and design principles.

When upstream behavior changes, update the script and explanatory document in the same commit. Avoid preserving an obsolete command merely because it once appeared in a popular article.
