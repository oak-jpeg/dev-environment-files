# My Dev Environment Files 🚀

Personal macOS dev environment configs — originally inspired by [josean-dev/dev-environment-files](https://github.com/josean-dev/dev-environment-files), then restyled after [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles) (fish+Tide, LazyVim, Solarized Dark). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

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

## Terminal — WezTerm

Config: [`wezterm/.wezterm.lua`](wezterm/.wezterm.lua)

Theme is WezTerm's builtin `Solarized Dark - Patched` scheme (same name/palette as the Ghostty config that got tried and removed earlier — this is that same look, just in WezTerm instead), with `background` overridden to `#031219`. `window_background_opacity = 0.9` + `macos_window_background_blur = 20` let the desktop wallpaper show through blurred, matching the look in craftzdog's own screenshots. `JetBrainsMono NF` font, `Cmd+Enter` toggles fullscreen, `Cmd+W` closes the current pane. Tab bar is on but auto-hides when there's only one tab (`hide_tab_bar_if_only_one_tab`) — switch tabs with `Cmd+1`–`Cmd+9` or `Cmd+Shift+[` / `Cmd+Shift+]`.

Tmux session handling: the **first window** when WezTerm itself launches (via a `gui-startup` handler) attaches to the persistent `main` session — same one every time, survives quitting and reopening WezTerm. **New tabs/windows opened afterward** (`Cmd+T`, `Cmd+N`) each get their own fresh, independent tmux session (`wezterm-<pid>`) instead of also attaching to `main` — otherwise every new tab just mirrored the same session (switch a window in one, all of them jump too), which is exactly what tmux does when two clients attach to the same session name. The tab bar had to come back on for this to be usable — with every tab silently mirroring `main` before, there was nothing to distinguish, but now they're genuinely different sessions, so you need a way to see and pick between them.

Ghostty and Alacritty were both tried at different points (see git history) but have been removed — sticking with WezTerm as the one terminal to configure and keep working.

### Requires

- [WezTerm](https://wezfurlong.org/wezterm/)
- `JetBrainsMono NF` (`font-jetbrains-mono-nerd-font` in the Brewfile)

## Shell setup (macOS & Linux)

**Current default: Zsh** (see below) — Fish is fully installed and configured but sits on the sidelines for now because of an unresolved Tide rendering bug (see the callout further down). Switch to it once that's sorted: `chsh -s $(which fish)`.

Fish config: [`fish/.config/fish`](fish/.config/fish)

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
- [fastfetch](https://github.com/fastfetch-cli/fastfetch) — system info banner on every new interactive shell, curated to a shorter module list (`os`/`host`/`kernel`/`uptime`/`packages`/`shell`/`terminal`/`cpu`/`memory`/`colors`) with key/title colors set to the Solarized accent colors used elsewhere ([`fastfetch/.config/fastfetch/config.jsonc`](fastfetch/.config/fastfetch/config.jsonc))

Not ported: craftzdog's `mise` (would double up with pyenv/nvm.fish, which are already wired and tested here) and his fish `theme_*` variables (leftover config for a different, pre-Tide fish theme — inert either way).

**⚠️ Open issue — Tide renders a permanently blank/near-empty prompt on this machine, unresolved.** In real use (originally observed in Ghostty, since removed from this setup — untested in WezTerm), the `pwd`/`git` segments never render (only `character` and the right-side items like `context`/`cmd_duration` show up), even at a full-width terminal. What's been ruled out so far:

- A real, separate upstream bug **was** found and fixed: `set -U $prompt_var` in Tide's `fish_prompt.fish` spuriously fires the `--on-variable` repaint handler on first render, making the async job that computes prompt content think a repaint is already pending and skip itself ([ilancosman/tide#666](https://github.com/IlanCosman/tide/pull/666), unmerged). `install.sh` patches this automatically right after `fisher update` (which would otherwise silently reintroduce it) — but applying it alone did **not** fix the blank prompt, so something else is also going on.
- Not caused by `tide configure --auto`'s known blank-prompt issues — going through the interactive wizard start to finish changed nothing.
- Not a narrow-terminal issue — `$COLUMNS` reports 215.
- Not `tide_prompt_transient_enabled` getting stuck in its collapsed state — disabling it made no difference.
- Basic rendering (`echo hello`, the `tide configure` wizard's own colored preview) worked fine, so it isn't a font/color/terminal-capability problem in general.

Whoever picks this back up next: the leftover `_tide_repaint` patch and universal-variable cleanup in `install.sh` should stay (they fix a real bug, just not this whole symptom) — the next step is probably to trace why `_tide_pwd`'s output specifically never makes it into `$prompt_var` in a real interactive session, when it does under `script`/`expect`-simulated ptys. Consider filing an upstream issue with a minimal repro if it's not already covered by an open one.

## Shell — Zsh + Oh My Zsh + Powerlevel10k (current default)

Config: [`zsh/.zshrc`](zsh/.zshrc), [`zsh/.zprofile`](zsh/.zprofile), [`zsh/.p10k.zsh`](zsh/.p10k.zsh) — unchanged from before this whole fish/Tide detour. `chsh -s $(which zsh)` to switch back if you're on fish.

### Switching your login shell

```bash
echo $(which fish) | sudo tee -a /etc/shells   # if fish isn't listed yet
chsh -s $(which fish)
```

(`chsh` needs your account password interactively — run it yourself in a real terminal, not from a script.)

## Tmux

Config: [`tmux/.config/tmux/`](tmux/.config/tmux/) (`tmux.conf` + `macos.conf` — tmux picks this up automatically via its XDG config path since there's no `~/.tmux.conf` anymore)

**Keybindings — untouched, still mine** (`tmux.conf`):

- Prefix remapped `Ctrl-b` → `Ctrl-a`
- `|` / `-` split panes (instead of `%` / `"`), keeping the current pane's path
- `Alt+Arrow` to move between panes without the prefix, `prefix+Shift+Arrow` to resize
- `Ctrl+Shift+Arrow` (no prefix) swaps the current window's position left/right
- `prefix+y` opens [Claude Code](https://github.com/anthropics/claude-code) in a floating popup, running in its own tmux session per working directory
- Vi-style copy mode, `y` copies straight to `pbcopy`
- `prefix+r` reloads the config

**Look — Solarized Dark, status bar at the bottom, matched exactly to WezTerm.** Went through a few iterations here: craftzdog's ported `theme.conf`/`statusline.conf` clashed with what was then a One Dark WezTerm background; a plain One Dark status bar of its own then drifted a shade off (`#1a1a2e` vs. WezTerm's `#282c34`) and still looked like a seam. Now that WezTerm itself is Solarized Dark - Patched (`#031219` background, transparent + blurred so the desktop wallpaper shows through), the status bar uses that same background plus accents from that scheme's own ANSI palette (`#738a05` green, `#2176c7` blue, `#a57706` yellow) — same source of truth as the terminal, not picked separately. Because the background is a moving, semi-transparent wallpaper rather than a flat color, plain colored *text* wasn't reliably legible against it, so the session name, active window, and clock are drawn as solid filled blocks instead — readable no matter what's behind the window. First pass used dark navy (`#031219`) text on those blocks, which still wasn't legible enough against the medium-brightness green/blue fills, so the block text is now bright cream (`#fcf4dc`, Solarized's `base3`) instead. The less critical inactive window list stays as plain `#839496` (Solarized `base0`) text. `macos.conf` (`reattach-to-user-namespace` for clipboard, undercurl support) is kept since that's function, not color.

### Requires

- [tmux](https://github.com/tmux/tmux) ≥ 3.1 (for XDG config path support)
- [reattach-to-user-namespace](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard) (in the Brewfile)

## Neovim

Config: [`nvim/.config/nvim`](nvim/.config/nvim) — full [LazyVim](https://www.lazyvim.org/) distro config, ported wholesale from [craftzdog/dotfiles](https://github.com/craftzdog/dotfiles/tree/master/.config/nvim) (this replaces what used to be a submodule pointing at a kickstart.nvim fork). LSP/formatting extras: eslint, prettier, typescript, json, rust, tailwind.

**Colorscheme:** default is [solarized-osaka.nvim](https://github.com/craftzdog/solarized-osaka.nvim) (craftzdog's own theme, itself built on top of Solarized Dark + [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) — see [`lua/plugins/colorscheme.lua`](nvim/.config/nvim/lua/plugins/colorscheme.lua)). `tokyonight.nvim` (style `night`) is also installed as a switchable option — try it with `:colorscheme tokyonight-night`, and back with `:colorscheme solarized-osaka`. Both run `transparent = true`.

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
├── fish/.config/fish/                    (installed, not default — open Tide bug, see above)
├── zsh/.zshrc, .zprofile, .p10k.zsh      (current default)
├── tmux/.config/tmux/                    (tmux.conf, macos.conf)
├── nvim/.config/nvim/                    (full LazyVim config)
├── wezterm/.wezterm.lua                  (default terminal)
├── lazygit/.config/lazygit/config.yml
├── fastfetch/.config/fastfetch/config.jsonc
├── git/.gitconfig, .config/git/ignore, .config/git/delta.gitconfig
├── Brewfile
└── install.sh
```
