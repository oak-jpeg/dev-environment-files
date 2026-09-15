#!/usr/bin/env bash
#
# Bootstraps this machine's dev environment.
# Run from anywhere: ~/dev-environment-files/install.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

STOW_PACKAGES=(zsh git claude starship atuin)

echo "==> Installing Homebrew packages from Brewfile"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew bundle --file="$DOTFILES/Brewfile"

echo "==> Symlinking dotfiles with GNU Stow"
for pkg in "${STOW_PACKAGES[@]}"; do
  stow --target="$HOME" --restow --adopt "$pkg"
  git checkout -- "$pkg" 2>/dev/null || true
  echo "  stowed: $pkg"
done

echo "==> Done. Restart your terminal (or 'exec zsh') to pick up the new config."
