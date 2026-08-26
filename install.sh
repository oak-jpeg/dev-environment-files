#!/usr/bin/env bash
#
# Bootstraps this machine's dev environment.
# Run from anywhere: ~/dev-environment-files/install.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

STOW_PACKAGES=(zsh tmux nvim alacritty wezterm lazygit git)

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

echo "==> Symlinking dotfiles with GNU Stow"
for pkg in "${STOW_PACKAGES[@]}"; do
  stow --target="$HOME" --restow "$pkg"
  echo "  stowed: $pkg"
done

echo "==> Done. Restart your terminal (or 'exec zsh') to pick up the new config."
