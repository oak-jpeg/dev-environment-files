# My Dev Environment Files 🚀

Personal macOS dev environment configs — inspired by [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

**Note:** these are tuned for my own machine and workflow. Feel free to borrow ideas, but read before blindly running anything.

## Quick Start

```bash
git clone --recurse-submodules https://github.com/oak-jpeg/dev-environment-files.git ~/dev-environment-files
cd ~/dev-environment-files
./install.sh
```

`install.sh` installs Homebrew + everything in the `Brewfile`, pulls Oh My Zsh, fetches the neovim config submodule, then uses `stow` to symlink each package below into `$HOME`.

To (re)link a single package by hand:

```bash
stow --target="$HOME" zsh
```

## Terminal — WezTerm

Config: [`wezterm/.wezterm.lua`](wezterm/.wezterm.lua)

One Dark colors, `JetBrainsMono NF` font, tab bar disabled in favor of tmux's status bar, `Cmd+Enter` toggles fullscreen, `Cmd+W` closes the current pane. Opens straight into a tmux session on launch.

Also included: [`alacritty/.config/alacritty/alacritty.toml`](alacritty/.config/alacritty/alacritty.toml) as a fallback terminal config with the same theme/behavior.

### Requires

- [WezTerm](https://wezfurlong.org/wezterm/) or [Alacritty](https://alacritty.org/)
- A Nerd Font (`font-jetbrains-mono-nerd-font` / `font-meslo-lg-nerd-font`, both in the Brewfile)

## Shell — Zsh + Oh My Zsh + Powerlevel10k

Config: [`zsh/.zshrc`](zsh/.zshrc), [`zsh/.zprofile`](zsh/.zprofile), [`zsh/.p10k.zsh`](zsh/.p10k.zsh)

- Theme: `powerlevel10k`
- Plugins: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `command-not-found`, `colored-man-pages`
- `nvm` + `pyenv` for Node/Python version management
- `eza` aliased over `ls`/`ll`/`la` with icons
- `Ctrl-g` opens `lazygit` directly
- Aliases to start/stop local Postgres, MongoDB, and MySQL services via `brew services`

## Tmux

Config: [`tmux/.tmux.conf`](tmux/.tmux.conf)

- Prefix remapped `Ctrl-b` → `Ctrl-a`
- True color enabled for Neovim
- Mouse support on, 1-indexed windows/panes
- `|` / `-` split panes (instead of `%` / `"`), keeping the current pane's path
- `Alt+Arrow` to move between panes without the prefix, `prefix+Shift+Arrow` to resize
- Vi-style copy mode, `y` copies straight to `pbcopy`
- `prefix+r` reloads the config

## Neovim

Config: [`nvim/.config/nvim`](nvim/.config/nvim) — pulled in as a git submodule from my separate [nvim-configs](https://github.com/peatiscoding/nvim-configs) repo (built on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim)).

### Requires

- Neovim ≥ 0.9
- [ripgrep](https://github.com/BurntSushi/ripgrep) (Telescope live grep)
- Node ≥ 16 (for LSP/formatter tooling, e.g. `prettierd`)
- A Nerd Font in your terminal

On first launch, `lazy.nvim` installs plugins automatically — wait for that (and any Mason LSP installs) to finish.

## Lazygit

Config: [`lazygit/.config/lazygit/config.yml`](lazygit/.config/lazygit/config.yml)

Custom command bound to `Ctrl-a` in the files context: stages the diff, asks Claude Code (`claude -p`) to write a conventional commit message, and commits with it.

### Requires

- [lazygit](https://github.com/jesseduffield/lazygit)
- [Claude Code CLI](https://github.com/anthropics/claude-code) (`claude`) on `$PATH` and logged in

## Git

Config: [`git/.gitconfig`](git/.gitconfig), [`git/.config/git/ignore`](git/.config/git/ignore)

- `git pull` always rebases
- `nano` as the default editor
- Global ignore for `**/.claude/settings.local.json`
- Git LFS filters configured

## Homebrew

[`Brewfile`](Brewfile) — everything above, dumped with `brew bundle dump`. Reinstall on a new machine with:

```bash
brew bundle
```

## Layout

Each top-level directory is a Stow "package" mirroring the `$HOME` paths it should be symlinked to:

```
dev-environment-files/
├── zsh/.zshrc, .zprofile, .p10k.zsh
├── tmux/.tmux.conf
├── nvim/.config/nvim/          (submodule)
├── alacritty/.config/alacritty/alacritty.toml
├── wezterm/.wezterm.lua
├── lazygit/.config/lazygit/config.yml
├── git/.gitconfig, .config/git/ignore
├── Brewfile
└── install.sh
```
