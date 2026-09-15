# ---- COMPLETIONS (was handled by oh-my-zsh.sh before we dropped it) ----
autoload -Uz compinit && compinit

# ---- PROMPT & SHELL HISTORY ----
eval "$(starship init zsh)"
eval "$(atuin init zsh)"

# ---- TOOLCHAIN & NAVIGATION ----
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"

# ---- NVM ----
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

# ---- PYENV ----
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# ---- LS WITH ICONS ----
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --group-directories-first"
alias la="eza -la --icons --group-directories-first"

# ---- ZSH Plugins ----
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="$HOME/.local/bin:$PATH"

bindkey -s "^g" "lazygit
"

# ---- SHORTKEY SERVICES  ----
alias pgstart='brew services start postgresql@16'
alias pgstop='brew services stop postgresql@16'
alias mongostart='brew services start mongodb-community@8.0'
alias mongostop='brew services stop mongodb-community@8.0'
alias mysqlstart='brew services start mysql'
alias mysqlstop='brew services stop mysql'

# ---- system info banner ----
command -v fastfetch >/dev/null && fastfetch
