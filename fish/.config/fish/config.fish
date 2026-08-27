set fish_greeting ""
set -gx EDITOR nvim

# ---- aliases (ported from craftzdog/dotfiles config.fish + config-osx.fish) ----
alias ls "ls -p -G"
alias la "ls -A"
alias g git
alias c claude
alias claude-yolo "claude --dangerously-skip-permissions"
command -q nvim && alias vim nvim

if type -q eza
    alias ll "eza -l -g --icons"
else
    alias ll "ls -l"
end
alias lla "ll -A"

# ---- PATH ----
fish_add_path $HOME/bin
fish_add_path $HOME/.local/bin
set -gx GOPATH $HOME/go
fish_add_path $GOPATH/bin
set -gx PATH node_modules/.bin $PATH

if status is-interactive
    # Homebrew's /opt/homebrew/bin is already on PATH via /etc/paths.d/homebrew
    # (fish runs path_helper as a login shell) — no brew shellenv needed here,
    # and adding it would re-prepend it in front of nvm.fish's active Node.

    # ---- pyenv ----
    set -gx PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
    pyenv init - fish | source

    # ---- fzf (Ctrl-R history, Ctrl-T files, Alt-C cd) ----
    fzf_configure_bindings
    set -g FZF_PREVIEW_FILE_CMD "bat --style=numbers --color=always --line-range :500"
    set -g FZF_LEGACY_KEYBINDINGS 0

    # ---- open lazygit ----
    bind \cg 'lazygit; commandline -f repaint'

    # ---- local service shortcuts ----
    alias pgstart="brew services start postgresql@16"
    alias pgstop="brew services stop postgresql@16"
    alias mongostart="brew services start mongodb-community@8.0"
    alias mongostop="brew services stop mongodb-community@8.0"
    alias mysqlstart="brew services start mysql"
    alias mysqlstop="brew services stop mysql"
end
