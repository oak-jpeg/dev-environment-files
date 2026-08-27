set fish_greeting ""
set -gx EDITOR nvim

if status is-interactive
    # Homebrew's /opt/homebrew/bin is already on PATH via /etc/paths.d/homebrew
    # (fish runs path_helper as a login shell) — no brew shellenv needed here,
    # and adding it would re-prepend it in front of nvm.fish's active Node.

    # ---- pyenv ----
    set -gx PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
    pyenv init - fish | source

    # ---- Go tools (gopls, staticcheck, ...) ----
    fish_add_path $HOME/go/bin

    # ---- fzf keybindings (Ctrl-R history, Ctrl-T files, Alt-C cd) ----
    fzf_configure_bindings

    # ---- ls with icons ----
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -l --icons --group-directories-first"
    alias la="eza -la --icons --group-directories-first"
    command -q nvim && alias vim nvim

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
