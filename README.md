# My Dev Environment Files 🚀

Personal macOS dev environment configs — originally inspired by [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files), restyled after [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles) (fish+Tide, LazyVim era), and now largely rebuilt around [mehd-io/dotfiles](https://github.com/mehd-io/dotfiles) for the terminal/tmux/window-management layer (Ghostty, tmux + Claude Code integration, AeroSpace, Sketchybar, Atuin, Borders — Catppuccin Mocha theme throughout, replacing the earlier Solarized look). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

**Note:** these are tuned for my own machine and workflow. Feel free to borrow ideas, but read before blindly running anything.

**On keybindings:** visuals/tools are frequently ported from other people's setups, but tmux's prefix and most of its custom bindings, lazygit's commit shortcut, and nvim's own keymaps are kept as my own where noted in each section below.

## Quick Start

```bash
git clone https://github.com/oak-jpeg/dev-environment-files.git ~/dev-environment-files
cd ~/dev-environment-files
./install.sh
```

`install.sh` installs Homebrew + everything in the `Brewfile`, pulls Oh My Zsh, bootstraps Fisher and syncs the fish plugins in `fish_plugins`, stows every package into `$HOME`, then bootstraps Neovim (`lazy.nvim` plugin sync + `mason` LSP/formatter installs — this step takes a few minutes on a fresh machine). It prints the `chsh` command to switch your login shell to fish — run that part yourself (needs interactive auth).

To (re)link a single package by hand:

```bash
stow --target="$HOME" fish
```

## Terminal — Ghostty

Config: [`ghostty/.config/ghostty/config`](ghostty/.config/ghostty/config), [`ghostty/tmux-attach.sh`](ghostty/tmux-attach.sh)

Switched here from WezTerm on 2026-09-15 (WezTerm and Alacritty were both tried at earlier points too — see git history for those configs). Theme `Catppuccin Mocha`, font `Hack Nerd Font Mono` at size 16, `background-blur-radius = 20` for the translucent-desktop look, block cursor with no blink, `macos-option-as-alt = true` so Option acts as Alt (used by the vim-mode bindings below).

Tmux session handling: every new Ghostty window/tab runs `command = tmux-attach.sh` instead of a plain shell, which always attaches to the same persistent tmux session named `session` (`tmux new-session -A -s session`) — one shared session across every window, unlike the old WezTerm setup which gave each new window/tab its own independent session. The script is its own file (rather than an inline `command =` string) because Ghostty splits `command` into argv on raw whitespace without shell parsing — quoting a multi-token tmux command directly in the config breaks silently. It's also a login shell (`#!/bin/zsh -l`) so `.zprofile` (which sets up `brew shellenv`) runs first; without that, the wrapper can't find `tmux` on `$PATH` at all.

Other keybinds: `Shift+Enter` inserts a literal newline instead of submitting, `Cmd+S` forwards a raw `Ctrl+S` to the shell/nvim (nvim maps `<C-s>` to `:w`), and `Alt+V` enters a vim-style key table for scrollback/search/copy (`j`/`k` line scroll, `Ctrl+D`/`Ctrl+U`/`Ctrl+F`/`Ctrl+B` page scroll, `gg`/`G` jump to top/bottom, `/` search, `v`/`y` copy to clipboard, `Esc`/`q`/`i` to exit the table).

### Requires

- [Ghostty](https://ghostty.org/)
- `Hack Nerd Font Mono` (`font-jetbrains-mono-nerd-font` / `font-meslo-lg-nerd-font` are also in the Brewfile for other tools that want those families specifically)

## Shell setup (macOS & Linux)

**Current default: Zsh** (see below) — Fish is fully installed and configured but sits on the sidelines for now because of an unresolved Tide rendering bug (see the callout further down). Switch to it once that's sorted: `chsh -s $(which fish)`.

Fish config: [`fish/.config/fish`](fish/.config/fish)

- [Fisher](https://github.com/jorgebucaran/fisher) — plugin manager, plugin list tracked in [`fish_plugins`](fish/.config/fish/fish_plugins)
- [Tide](https://github.com/IlanCosman/tide) — prompt theme (`conf.d/tide.fish`)
- [z](https://github.com/jethrokuan/z) — directory jumping
- [fzf.fish](https://github.com/PatrickF1/fzf.fish) — `Ctrl-R` history / `Ctrl-T` files / `Alt-C` cd, backed by [fzf](https://github.com/junegunn/fzf) and previewed with [bat](https://github.com/sharkdp/bat)
- [nvm.fish](https://github.com/jorgebucaran/nvm.fish) — Node version manager (auto-activates the pinned default on shell start)
- [pyenv](https://github.com/pyenv/pyenv) — Python version management
- [eza](https://github.com/eza-community/eza) — used for `ll`/`lla`; plain `ls`/`la` stay BSD `ls`
- [ghq](https://github.com/x-motemen/ghq) — local git repo organizer (root: `~/Developments/.ghq`, matching `.gitconfig` and the neovim `dev.path` below)
- Aliases: `g` → git, `c` → claude, `claude-yolo` → `claude --dangerously-skip-permissions`, `vim` → `nvim`
- `Ctrl-g` opens `lazygit` directly
- Aliases to start/stop local Postgres, MongoDB, and MySQL services via `brew services`
- [fastfetch](https://github.com/fastfetch-cli/fastfetch) — system info banner on every new interactive shell, curated to a shorter module list (`os`/`host`/`kernel`/`uptime`/`packages`/`shell`/`terminal`/`cpu`/`memory`/`colors`) ([`fastfetch/.config/fastfetch/config.jsonc`](fastfetch/.config/fastfetch/config.jsonc))

Not ported to fish: `mise` (fish already has nvm.fish/pyenv wired and tested — zsh, below, is the one that picked up `mise` instead) and Tide's inert leftover `theme_*` variables from a different, pre-Tide fish theme.

**⚠️ Open issue — Tide renders a permanently blank/near-empty prompt on this machine, unresolved.** Originally observed in Ghostty, then the terminal moved to WezTerm (untested there) and has since moved back to Ghostty (2026-09-15) — worth re-testing against current Ghostty before assuming it still reproduces. What's been ruled out so far:

- A real, separate upstream bug **was** found and fixed: `set -U $prompt_var` in Tide's `fish_prompt.fish` spuriously fires the `--on-variable` repaint handler on first render, making the async job that computes prompt content think a repaint is already pending and skip itself ([ilancosman/tide#666](https://github.com/IlanCosman/tide/pull/666), unmerged). `install.sh` patches this automatically right after `fisher update` (which would otherwise silently reintroduce it) — but applying it alone did **not** fix the blank prompt, so something else is also going on.
- Not caused by `tide configure --auto`'s known blank-prompt issues — going through the interactive wizard start to finish changed nothing.
- Not a narrow-terminal issue — `$COLUMNS` reports 215.
- Not `tide_prompt_transient_enabled` getting stuck in its collapsed state — disabling it made no difference.
- Basic rendering (`echo hello`, the `tide configure` wizard's own colored preview) worked fine, so it isn't a font/color/terminal-capability problem in general.

Whoever picks this back up next: the leftover `_tide_repaint` patch and universal-variable cleanup in `install.sh` should stay (they fix a real bug, just not this whole symptom) — the next step is probably to trace why `_tide_pwd`'s output specifically never makes it into `$prompt_var` in a real interactive session, when it does under `script`/`expect`-simulated ptys. Consider filing an upstream issue with a minimal repro if it's not already covered by an open one.

## Shell — Zsh + Starship + Atuin (current default)

Config: [`zsh/.zshrc`](zsh/.zshrc), [`zsh/.zprofile`](zsh/.zprofile). `chsh -s $(which zsh)` to switch back if you're on fish.

Zsh no longer runs through Oh My Zsh or Powerlevel10k for its interactive setup — `.zshrc` is a short, flat file: `compinit` for completions, then [Starship](https://starship.rs/) for the prompt, [Atuin](https://atuin.sh/) for shell history, [mise](https://mise.jdx.dev/) + [zoxide](https://github.com/ajeetdsouza/zoxide) for toolchain/navigation, nvm and pyenv sourced directly (not via a plugin manager), `zsh-autosuggestions` + `zsh-syntax-highlighting` sourced from Homebrew's share dir, the `eza`-backed `ls`/`ll`/`la` aliases, `Ctrl-g` bound to `lazygit`, the same Postgres/MongoDB/MySQL service aliases as fish, and the `fastfetch` banner at the end.

- **Starship** — [`starship/.config/starship.toml`](starship/.config/starship.toml). Segmented format (colored background blocks, powerline-style separators): os/username → directory → git branch/status → docker context → time.
- **Atuin** — [`atuin/.config/atuin/config.toml`](atuin/.config/atuin/config.toml). Takes over `Ctrl-R` and the up-arrow from plain zsh history, with `enter_accept = true` (hitting enter on a searched command runs it immediately; `Tab` returns it to the prompt for editing instead) and sync v2 (`records = true`) enabled, though not logged into a sync server on this machine. ⚠️ **Atuin only indexes what it's seen since it was installed/imported** — it does not automatically backfill from an existing `.zsh_history`. After first install (or if search suddenly looks like history "vanished" even though `.zsh_history` is intact), run `atuin import zsh` once to backfill.
- **mise** — activated but overlaps in scope with the fish-side nvm.fish/pyenv; not yet reconciled into one toolchain manager across both shells.

### Switching your login shell

```bash
echo $(which fish) | sudo tee -a /etc/shells   # if fish isn't listed yet
chsh -s $(which fish)
```

(`chsh` needs your account password interactively — run it yourself in a real terminal, not from a script.)

## Tmux

Config: [`tmux/.tmux.conf`](tmux/.tmux.conf) (base, do not edit directly) + [`tmux/.tmux.conf.local`](tmux/.tmux.conf.local) (all overrides live here) + helper scripts in [`tmux/.tmux/`](tmux/.tmux/)

Base is [gpakosz/.tmux](https://github.com/gpakosz/.tmux) — a themable tmux config framework — instead of a hand-rolled `tmux.conf`. `.tmux.conf.local` overrides its `tmux_conf_theme_*` variables for a Catppuccin Mocha look (focused-pane border, status line, window tabs) and adds everything custom on top.

**Keybindings:**

- Prefix remapped `Ctrl-b` → `Ctrl-a` (both of gpakosz's default prefixes are unbound first, then `Ctrl-a` set explicitly)
- `h`/`j`/`k`/`l` (no prefix needed via the framework's pane-nav bindings) to move between panes, `|`/`-` to split (vertical/horizontal, mnemonic-matched), `Shift+H/J/K/L` to resize
- `prefix+n` toggles a nvim pane open/closed (`toggle-nvim.sh`)
- `prefix+C` / `prefix+V` / `prefix+H` — new window / vertical split / horizontal split, each running [Claude Code](https://github.com/anthropics/claude-code) directly
- `prefix+y` — floating Claude popup in its own persistent tmux session keyed by the current directory's path hash, so returning to the same project reattaches the same conversation
- `prefix+f` — opens a new window running `claude-search.sh` to search past Claude conversations
- `prefix+u` — popup to open a URL found in the current pane (`open-url.sh`)
- `prefix+L` — toggle a bottom log pane (`log-pane.sh`)
- `prefix+S` — fuzzy session switcher via `fzf` in a popup
- `prefix+q` — kill the current window, with a confirm prompt
- `prefix+r` — reload config (from the gpakosz base)
- Windows auto-rename to the current folder's basename; a `pane-exited` hook (`tmux-cleanup.sh`) kills stray processes/devcontainers tied to a pane once its last pane for that repo closes
- Pane border info bar (`pane-border-status top`) shows live per-pane info via `pane-info.sh`; the status bar itself refreshes every second so Claude's busy/idle/waiting state (`claude-on-busy.sh`, `claude-on-idle.sh`, `claude-on-waiting.sh`, `claude-statusline.sh`) shows up close to live
- Mouse mode on

**Look:** [catppuccin/tmux](https://github.com/catppuccin/tmux) via [TPM](https://github.com/tmux-plugins/tpm), flavor `mocha`, rounded window tabs, minimal status line (nothing on the left; app/directory/session on the right) — everything else (pane borders, prefix binding, custom key tables) stays gpakosz's own theming. The catppuccin plugin's status-line variables are re-applied on a `client-attached` hook, since gpakosz's own `_apply_theme` runs after the config file loads and would otherwise silently stomp a plain `status-left`/`status-right` set earlier in the file. `tmux-resurrect` + `tmux-continuum` are also loaded, with `@continuum-restore 'on'` so sessions survive a reboot.

### TPM setup

`install.sh` clones both TPM and `catppuccin/tmux` directly (not via TPM's own headless installer — it expects an already-running tmux server to query, which doesn't exist yet on a fresh machine, and the config's `run "~/.tmux/plugins/tmux/catppuccin.tmux"` line would itself error on load if that file isn't there first). To add more plugins later, list them with `set -g @plugin '...'` above the `run '~/.tmux/plugins/tpm/tpm'` line at the bottom of `.tmux.conf.local`, then press `prefix + I` inside a live tmux session to fetch them.

### Requires

- [tmux](https://github.com/tmux/tmux) ≥ 3.1
- [reattach-to-user-namespace](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard) (in the Brewfile)
- [fzf](https://github.com/junegunn/fzf) (for `prefix+S`)
- [TPM](https://github.com/tmux-plugins/tpm) + [catppuccin/tmux](https://github.com/catppuccin/tmux) + `tmux-resurrect`/`tmux-continuum` — cloned/fetched by `install.sh`/TPM, not tracked in this repo
- [Claude Code CLI](https://github.com/anthropics/claude-code) (`claude`) on `$PATH` for the Claude-specific bindings
- A Nerd Font, for the window-style icons

## Window management — AeroSpace + Sketchybar + Borders

Three pieces that work together and all run as background services/apps:

- **[AeroSpace](https://nikitabobko.github.io/AeroSpace/)** — [`aerospace/.config/aerospace/aerospace.toml`](aerospace/.config/aerospace/aerospace.toml). Tiling window manager, `config-version = 2` with 7 persistent workspaces (`alt-1`..`alt-7`). `alt-hjkl` to focus, `alt-shift-hjkl` to move, `alt-e`/`alt-,` to switch tile/accordion layout, `alt-f` fullscreen. Per-app `alt-<letter>` launchers (Brave, Ghostty, Cursor, Slack, Discord, Premiere, OBS, Obsidian, Notion, Claude), plus `on-window-detected` rules that auto-assign specific apps to specific workspaces on launch. `outer.top` gaps are set per-monitor (`8` on the main display, `40` on any other) to leave room for the menu bar plus the Sketchybar height, since macOS reserves menu-bar space differently per monitor. Every workspace change fires a `sketchybar --trigger aerospace_workspace_change` event to keep the bar's icons in sync.
- **[Sketchybar](https://felixkratz.github.io/SketchyBar/)** — [`sketchybar/.config/sketchybar/`](sketchybar/.config/sketchybar/) (`sketchybarrc` + `items/` + `plugins/`). Custom top status bar (height 40, blurred background) with per-workspace app icons driven by the AeroSpace event above, plus battery/clock/volume/front-app/VPN plugins.
- **[Borders](https://github.com/FelixKratz/JankyBorders)** — [`borders/.config/borders/bordersrc`](borders/.config/borders/bordersrc). Just a focused/unfocused window border (round style, 4.5px), nothing else.

### Requires

- AeroSpace, Sketchybar, Borders (`brew services start` for the latter two — both run via a LaunchAgent, see `Brewfile`)
- `Hack Nerd Font` (Sketchybar icon glyphs)

## Neovim

Config: [`nvim/.config/nvim`](nvim/.config/nvim) — the stock [LazyVim starter](https://github.com/LazyVim/starter) template, largely unmodified, plus one custom plugin spec: [`lua/plugins/git-review.lua`](nvim/.config/nvim/lua/plugins/git-review.lua) adds [codediff.nvim](https://github.com/esmuellert/codediff.nvim) (`<leader>gd` → `:CodeDiff`). `lua/plugins/example.lua` is the starter's own inert example spec (guarded by `if true then return {} end`) — kept as reference, not loaded.

This replaces an earlier, more heavily customized config ported from [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles) (custom `solarized-osaka` colorscheme, hand-written LSP/util modules, its own keymaps) — that's been dropped in favor of the plain starter defaults (colorscheme, keymaps, options, autocmds all stock LazyVim now). If you want that older look/behavior back, it's in git history.

### Requires

- Neovim ≥ 0.9 (built with LuaJIT)
- Git ≥ 2.19 (partial clone support)
- [ripgrep](https://github.com/BurntSushi/ripgrep) + [fd](https://github.com/sharkdp/fd) (Telescope)
- A C compiler (nvim-treesitter) + `make` (telescope-fzf-native)
- [luarocks](https://luarocks.org/) (Mason needs it for `luacheck`)
- Node (typescript/eslint/tailwind tooling)
- A Nerd Font

On first launch, `lazy.nvim` installs all plugins and `mason` installs `codelldb`, `luacheck`, `prettier`, `selene`, `shellcheck`, `shfmt`, `stylua`, `tailwindcss-language-server`, `typescript-language-server`, `css-lsp` automatically — `install.sh` already runs this non-interactively so a fresh clone should come up plugin-complete.

## Lazygit

Config: [`lazygit/.config/lazygit/config.yml`](lazygit/.config/lazygit/config.yml)

Custom command bound to `Ctrl-a` in the files context: stages the diff, asks Claude Code (`claude -p`) to write a conventional commit message, and commits with it. `gui.mouseEvents: false`.

### Requires

- [lazygit](https://github.com/jesseduffield/lazygit)
- [Claude Code CLI](https://github.com/anthropics/claude-code) (`claude`) on `$PATH` and logged in

## Git

Config: [`git/.gitconfig`](git/.gitconfig), [`git/.config/git/ignore`](git/.config/git/ignore), [`git/.config/git/delta.gitconfig`](git/.config/git/delta.gitconfig)

- `editor = nvim`, `pager = delta` (Monokai Extended syntax theme, decorations)
- `diff`/`mergetool` set to `nvimdiff`
- `ghq.root = ~/Developments/.ghq` (matches the neovim `dev.path` above)
- `init.defaultBranch = main`
- `pull.rebase = false`
- Global ignore for `**/.claude/settings.local.json`
- Git LFS filters configured

### Requires

- [git-delta](https://github.com/dandavison/delta) (in the Brewfile)

## Claude Code settings

[`claude-settings-reference/settings.json.reference`](claude-settings-reference/settings.json.reference) is a **reference copy** of the live `~/.claude/settings.json`, not a stow symlink — that file loads at Claude Code startup, so it's kept as a plain reviewed file to avoid a `git pull` here silently changing live startup behavior on any machine. Update the reference copy by hand after editing the real file if you want the repo to reflect it. See [`claude-settings-reference/README.md`](claude-settings-reference/README.md).

## Homebrew

[`Brewfile`](Brewfile) — everything above, dumped with `brew bundle dump`. Reinstall on a new machine with:

```bash
brew bundle
```

## Layout

Each top-level directory is a Stow "package" mirroring the `$HOME` paths it should be symlinked to:

```
dev-environment-files/
├── ghostty/.config/ghostty/config, tmux-attach.sh   (default terminal)
├── fish/.config/fish/                    (installed, not default — open Tide bug, see above)
├── zsh/.zshrc, .zprofile                 (current default — Starship + Atuin)
├── starship/.config/starship.toml
├── atuin/.config/atuin/config.toml
├── tmux/.tmux.conf, .tmux.conf.local, .tmux/*.sh
├── aerospace/.config/aerospace/aerospace.toml
├── sketchybar/.config/sketchybar/
├── borders/.config/borders/bordersrc
├── nvim/.config/nvim/                    (LazyVim starter + git-review.lua)
├── lazygit/.config/lazygit/config.yml
├── fastfetch/.config/fastfetch/config.jsonc
├── git/.gitconfig, .config/git/ignore, .config/git/delta.gitconfig
├── claude-settings-reference/            (reference only, not stowed)
├── Brewfile
└── install.sh
```
