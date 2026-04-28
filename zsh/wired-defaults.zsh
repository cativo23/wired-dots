# shellcheck shell=bash
# wired-dots — framework-managed zsh defaults
#
# Symlinked to ~/.config/zsh/wired-defaults.zsh by the installer. Sourced
# from .zshrc BEFORE user.zsh so this file owns the "infrastructure"
# layer (env vars, plugin loaders, package update helpers) while user.zsh
# owns user-customizable pieces (project nav, personal aliases).
#
# Re-running ./install.sh DOES overwrite this file. Anything you want
# preserved across updates belongs in user.zsh (one-time copy on first
# install) or user.local.zsh (gitignored, never touched by installer).

# Show fastfetch on interactive shells. Kept here because it ships with
# wired-dots and is part of the "first-impression" UX.
if [[ $- == *i* ]]; then
    command -v fastfetch >/dev/null && fastfetch --logo-type file
fi

# Default editor. Override in user.zsh / user.local.zsh.
export EDITOR="${EDITOR:-nano}"

# NVM (load only if the Arch nvm package is installed).
[[ -f /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh

# System update — opinionated but useful default.
alias sysup='paru -Syu --noconfirm 2>/dev/null || yay -Syu --noconfirm; flatpak update 2>/dev/null'
