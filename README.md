# My Dev Environment Files 🚀

Personal macOS dev environment configs — originally inspired by [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files), now largely restyled after [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles) (Solarized everywhere, Ghostty, fish+Tide, LazyVim). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

**Note:** these are tuned for my own machine and workflow. Feel free to borrow ideas, but read before blindly running anything.

**On keybindings:** the visuals/tools here were deliberately ported from craftzdog's setup, but all the actual keybindings (tmux prefix `Ctrl-a` and its bindings, nvim's `lua/config/keymaps.lua`, lazygit's commit shortcut) are kept as my own — see each section below for what that means in practice.

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

Config: [`ghostty/.config/ghostty/config`](ghostty/.config/ghostty/config)

Theme `Solarized Dark Patched`, `PlemolJP Console NF` font, 90% background opacity with blur, block cursor with blink. Ported straight from craftzdog's config — the only thing intentionally left out is his `alt+left`/`alt+right` keybind unbinds, since that's a shortkey change and out of scope here.

Kept around for reference (no longer the default): [`wezterm/.wezterm.lua`](wezterm/.wezterm.lua), [`alacritty/.config/alacritty/alacritty.toml`](alacritty/.config/alacritty/alacritty.toml) — both auto-launch a tmux session on open; Ghostty currently doesn't (matching craftzdog, who starts tmux manually). Add a `command` line to `ghostty/.config/ghostty/config` if you want that back.

### Requires

- [Ghostty](https://ghostty.org/)
- `PlemolJP Console NF` (`font-plemol-jp-nf` in the Brewfile)

## Shell setup (macOS & Linux)

Default shell: [Fish](https://fishshell.com/) — config: [`fish/.config/fish`](fish/.config/fish)

- [Fisher](https://github.com/jorgebucaran/fisher) — plugin manager, plugin list tracked in [`fish_plugins`](fish/.config/fish/fish_plugins)
- [Tide](https://github.com/IlanCosman/tide) — prompt theme (Solarized git-segment colors in `conf.d/tide.fish`, ported from craftzdog)
- [z](https://github.com/jethrokuan/z) — directory jumping
- [fzf.fish](https://github.com/PatrickF1/fzf.fish) — `Ctrl-R` history / `Ctrl-T` files / `Alt-C` cd, backed by [fzf](https://github.com/junegunn/fzf) and previewed with [bat](https://github.com/sharkdp/bat)
- [nvm.fish](https://github.com/jorgebucaran/nvm.fish) — Node version manager (auto-activates the pinned default on shell start)
- [pyenv](https://github.com/pyenv/pyenv) — Python version management
- [eza](https://github.com/eza-community/eza) — used for `ll`/`lla`; plain `ls`/`la` stay BSD `ls`, matching craftzdog's config.fish
- [ghq](https://github.com/x-motemen/ghq) — local git repo organizer (root: `~/Developments/.ghq`, matching his `.gitconfig` and the neovim `dev.path` below)
- Aliases: `g` → git, `c` → claude, `claude-yolo` → `claude --dangerously-skip-permissions`, `vim` → `nvim`
- `Ctrl-g` opens `lazygit` directly (unchanged from before — my own binding, not his)
- Aliases to start/stop local Postgres, MongoDB, and MySQL services via `brew services`

Not ported: craftzdog's `mise` (would double up with pyenv/nvm.fish, which are already wired and tested here) and his fish `theme_*` variables (leftover config for a different, pre-Tide fish theme — inert either way).

Legacy config kept around: [Zsh + Oh My Zsh + Powerlevel10k](zsh/.zshrc) ([`zsh/.zprofile`](zsh/.zprofile), [`zsh/.p10k.zsh`](zsh/.p10k.zsh)). Still installed and usable (`chsh -s $(which zsh)`), just no longer the default.

### Switching your login shell

```bash
echo $(which fish) | sudo tee -a /etc/shells   # if fish isn't listed yet
chsh -s $(which fish)
```

(`chsh` needs your account password interactively — run it yourself in a real terminal, not from a script.)

## Tmux

Config: [`tmux/.config/tmux/`](tmux/.config/tmux/) (`tmux.conf` + `theme.conf` + `statusline.conf` + `macos.conf`, following craftzdog's file split — tmux picks this up automatically via its XDG config path since there's no `~/.tmux.conf` anymore)

**Keybindings — untouched, still mine** (`tmux.conf`):

- Prefix remapped `Ctrl-b` → `Ctrl-a`
- `|` / `-` split panes (instead of `%` / `"`), keeping the current pane's path
- `Alt+Arrow` to move between panes without the prefix, `prefix+Shift+Arrow` to resize
- `Ctrl+Shift+Arrow` (no prefix) swaps the current window's position left/right
- `prefix+y` opens [Claude Code](https://github.com/anthropics/claude-code) in a floating popup, running in its own tmux session per working directory
- Vi-style copy mode, `y` copies straight to `pbcopy`
- `prefix+r` reloads the config

**Look — ported from craftzdog** (`theme.conf` + `statusline.conf` + `macos.conf`): Solarized color scheme (256-color base + true-color status line), `reattach-to-user-namespace` for clipboard, undercurl support. His own keybindings from `utility.conf`/`macos.conf` (`Ctrl-t` prefix, `tmux-pain-control`, `bind o`/`bind -r e`, the `lazygit`-as-popup binding) were **not** ported — those are shortkeys, and I already have my own equivalents (Claude popup above; lazygit opens via `Ctrl-g` in the shell instead). `escape-time`/`default-terminal` were also left as my existing values (tuned for Neovim responsiveness) rather than his, since those are performance settings, not "style."

### Requires

- [tmux](https://github.com/tmux/tmux) ≥ 3.1 (for XDG config path support)
- [reattach-to-user-namespace](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard) (in the Brewfile)

## Neovim

Config: [`nvim/.config/nvim`](nvim/.config/nvim) — full [LazyVim](https://www.lazyvim.org/) distro config, ported wholesale from [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles/tree/master/.config/nvim) (this replaces what used to be a submodule pointing at a kickstart.nvim fork). Colorscheme: [solarized-osaka.nvim](https://github.com/craftzdog/solarized-osaka.nvim). LSP/formatting extras: eslint, prettier, typescript, json, rust, tailwind.

**The one file NOT ported: [`lua/config/keymaps.lua`](nvim/.config/nvim/lua/config/keymaps.lua)** — that's kept as my own (window nav `Ctrl-h/j/k/l`, `<leader>q`/`<leader>w`, `Esc` clears search, `J`/`K` move selected lines in visual mode). Everything else — `options.lua`, `autocmds.lua`, `lazy.lua`, the `craftzdog/*.lua` utility modules, and every file under `lua/plugins/` (including their bundled keymaps for telescope, git.nvim, close-buffers, etc., since those are inseparable from the plugins themselves) — is his, as-is.

### Requires

- Neovim ≥ 0.9 (built with LuaJIT)
- Git ≥ 2.19 (partial clone support)
- [ripgrep](https://github.com/BurntSushi/ripgrep) + [fd](https://github.com/sharkdp/fd) (Telescope)
- A C compiler (nvim-treesitter) + `make` (telescope-fzf-native)
- [luarocks](https://luarocks.org/) (Mason needs it for `luacheck`)
- Node (typescript/eslint/tailwind tooling), fish as `$SHELL` (set in `options.lua`)
- A Nerd Font

On first launch, `lazy.nvim` installs all plugins and `mason` installs `codelldb`, `luacheck`, `prettier`, `selene`, `shellcheck`, `shfmt`, `stylua`, `tailwindcss-language-server`, `typescript-language-server`, `css-lsp` automatically — `install.sh` already runs this non-interactively so a fresh clone should come up plugin-complete.

## Lazygit

Config: [`lazygit/.config/lazygit/config.yml`](lazygit/.config/lazygit/config.yml)

Custom command bound to `Ctrl-a` in the files context: stages the diff, asks Claude Code (`claude -p`) to write a conventional commit message, and commits with it — kept as-is (craftzdog binds `C` to `git cz`/commitizen instead; not ported since it's a shortkey). `gui.mouseEvents: false` is ported from his config.

### Requires

- [lazygit](https://github.com/jesseduffield/lazygit)
- [Claude Code CLI](https://github.com/anthropics/claude-code) (`claude`) on `$PATH` and logged in

## Git

Config: [`git/.gitconfig`](git/.gitconfig), [`git/.config/git/ignore`](git/.config/git/ignore), [`git/.config/git/delta.gitconfig`](git/.config/git/delta.gitconfig)

- `editor = nvim`, `pager = delta` (Monokai Extended syntax theme, decorations — ported from craftzdog)
- `diff`/`mergetool` set to `nvimdiff`
- `ghq.root = ~/Developments/.ghq` (matches the neovim `dev.path` above)
- `init.defaultBranch = main`
- **`pull.rebase = false`** — ⚠️ this flips my previous default (`rebase = true`) to match his config exactly. Worth knowing since it changes how `git pull` behaves on every repo, not just this one.
- Global ignore for `**/.claude/settings.local.json` (unchanged)
- Git LFS filters configured (unchanged)
- His `[alias]` block (`git st`, `git co`, `git hist`, ...) was **not** ported — those are shortkeys too, and several depend on `peco`, which isn't installed here.
- His `core.excludesfile = ~/.gitignore` line was also skipped — that would've silently replaced the existing `~/.config/git/ignore` global-ignore file (and I don't have the contents of his personal `~/.gitignore` to merge in).

### Requires

- [git-delta](https://github.com/dandavison/delta) (in the Brewfile)

## Homebrew

[`Brewfile`](Brewfile) — everything above, dumped with `brew bundle dump`. Reinstall on a new machine with:

```bash
brew bundle
```

## Layout

Each top-level directory is a Stow "package" mirroring the `$HOME` paths it should be symlinked to:

```
dev-environment-files/
├── fish/.config/fish/                    (default shell)
├── zsh/.zshrc, .zprofile, .p10k.zsh      (legacy, still usable)
├── tmux/.config/tmux/                    (tmux.conf, theme.conf, statusline.conf, macos.conf)
├── nvim/.config/nvim/                    (full LazyVim config)
├── ghostty/.config/ghostty/config        (default terminal)
├── alacritty/.config/alacritty/alacritty.toml   (legacy)
├── wezterm/.wezterm.lua                  (legacy)
├── lazygit/.config/lazygit/config.yml
├── git/.gitconfig, .config/git/ignore, .config/git/delta.gitconfig
├── Brewfile
└── install.sh
```
