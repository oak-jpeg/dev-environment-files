#!/usr/bin/env bash
#
# Bootstraps this machine's dev environment.
# Run from anywhere: ~/dev-environment-files/install.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

STOW_PACKAGES=(zsh fish tmux nvim alacritty wezterm lazygit git)

echo "==> Installing Homebrew packages from Brewfile"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew bundle --file="$DOTFILES/Brewfile"

echo "==> Fetching nvim config submodule"
git submodule update --init --recursive

echo "==> Installing Oh My Zsh (if missing)"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "==> Bootstrapping Fisher + fish plugins (tide, z, fzf.fish, nvm.fish)"
FISH_BIN="$(command -v fish)"
if [ -n "$FISH_BIN" ]; then
  "$FISH_BIN" -c '
    if not functions -q fisher
      curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
      fisher install jorgebucaran/fisher
    end
  '
  grep -qxF "$FISH_BIN" /etc/shells || echo "  NOTE: run: echo $FISH_BIN | sudo tee -a /etc/shells"
  echo "  NOTE: set as default shell with: chsh -s $FISH_BIN"
fi

echo "==> Symlinking dotfiles with GNU Stow"
for pkg in "${STOW_PACKAGES[@]}"; do
  stow --target="$HOME" --restow --adopt "$pkg"
  git checkout -- "$pkg" 2>/dev/null || true
  echo "  stowed: $pkg"
done

echo "==> Syncing fish plugins declared in fish_plugins"
if [ -n "$FISH_BIN" ]; then
  "$FISH_BIN" -c 'fisher update'
fi

echo "==> Done. Restart your terminal (or 'exec fish' / 'exec zsh') to pick up the new config."
