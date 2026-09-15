# My Dev Environment Files 🚀

Personal macOS dev environment configs — kept deliberately minimal: zsh with a Starship prompt and Atuin-backed history, base git config, and a couple of Claude Code hooks. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

**Note:** these are tuned for my own machine and workflow. Feel free to borrow ideas, but read before blindly running anything.

**2026-09-15:** stripped out a much larger setup that had grown to cover the terminal emulator, tmux, a tiling window manager, a status bar, and a full Neovim distro — all of that is gone (uninstalled, not just unstowed) except for what's documented below. If you want any of it back, it's in git history.

## Quick Start

```bash
git clone https://github.com/oak-jpeg/dev-environment-files.git ~/dev-environment-files
cd ~/dev-environment-files
./install.sh
```

`install.sh` installs Homebrew + everything in the `Brewfile`, then stows every package into `$HOME`.

To (re)link a single package by hand:

```bash
stow --target="$HOME" zsh
```

## Shell — Zsh + Starship + Atuin

Config: [`zsh/.zshrc`](zsh/.zshrc), [`zsh/.zprofile`](zsh/.zprofile)

`.zshrc` is a short, flat file: `compinit` for completions, [Starship](https://starship.rs/) for the prompt, [Atuin](https://atuin.sh/) for shell history, [mise](https://mise.jdx.dev/) + [zoxide](https://github.com/ajeetdsouza/zoxide) for toolchain/navigation, nvm and pyenv sourced directly, `zsh-autosuggestions` + `zsh-syntax-highlighting` from Homebrew's share dir, `eza`-backed `ls`/`ll`/`la` aliases, and aliases to start/stop local Postgres/MongoDB/MySQL via `brew services`.

- **Starship** — [`starship/.config/starship.toml`](starship/.config/starship.toml). Segmented powerline-style format: username → directory → git branch/status → docker context → time.
- **Atuin** — [`atuin/.config/atuin/config.toml`](atuin/.config/atuin/config.toml). Takes over `Ctrl-R` and the up-arrow from plain zsh history, with `enter_accept = true` (enter on a searched command runs it immediately; `Tab` returns it to the prompt) and sync v2 (`records = true`) enabled, though not logged into a sync server on this machine. ⚠️ **Atuin only indexes what it's seen since it was installed** — it does not automatically backfill from an existing `.zsh_history`. If search suddenly looks like history "vanished" even though `.zsh_history` is intact, run `atuin import zsh` once to backfill.

## Git

Config: [`git/.gitconfig`](git/.gitconfig), [`git/.config/git/ignore`](git/.config/git/ignore), [`git/.config/git/delta.gitconfig`](git/.config/git/delta.gitconfig)

- `editor = vi`, `pager = delta` (Monokai Extended syntax theme, decorations)
- `ghq.root = ~/Developments/.ghq`
- `init.defaultBranch = main`
- `pull.rebase = false`
- Global ignore for `**/.claude/settings.local.json`
- Git LFS filters configured

### Requires

- [git-delta](https://github.com/dandavison/delta) (in the Brewfile)

## Claude Code hooks

[`claude/.claude/hooks/`](claude/.claude/hooks/) — see [`claude/README.md`](claude/README.md) for what each hook does. `claude/settings.json.reference` is a reference copy of the live `~/.claude/settings.json` (not stowed, same reasoning as everywhere else that file matters: it loads at Claude Code startup, so it stays a plain reviewed file instead of a symlink).

## Homebrew

[`Brewfile`](Brewfile) — dumped with `brew bundle dump`. Reinstall on a new machine with:

```bash
brew bundle
```

## Layout

```
dev-environment-files/
├── zsh/.zshrc, .zprofile
├── starship/.config/starship.toml
├── atuin/.config/atuin/config.toml
├── git/.gitconfig, .config/git/ignore, .config/git/delta.gitconfig
├── claude/.claude/hooks/*.sh, settings.json.reference (not stowed), README.md
├── Brewfile
└── install.sh
```
