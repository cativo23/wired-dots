# wired-dots — user zsh config
# Sourced by zsh after framework init. No HyDE-specific hooks here.

# Startup: fastfetch on interactive shell
if [[ $- == *i* ]]; then
    command -v fastfetch >/dev/null && fastfetch --logo-type file
fi

# Quick navigation
alias cdp='cd ~/projects/personal'
alias cdw='cd ~/projects/work'
alias lsp='ls -1 ~/projects/personal'
alias lsw='ls -1 ~/projects/work'

# Tool aliases
alias cat='bat --theme=tokyonight_night'
alias sysup='paru -Syu --noconfirm 2>/dev/null || yay -Syu --noconfirm; flatpak update'

# Project management
mkpersonal() {
    mkdir -p ~/projects/personal/"$1" && cd ~/projects/personal/"$1" || return
}

mkwork() {
    mkdir -p ~/projects/work/"$1"/"$2" && cd ~/projects/work/"$1"/"$2" || return
}

archive_project() {
    if [[ -d ~/projects/work/"$1"/"$2" ]]; then
        mv ~/projects/work/"$1"/"$2" ~/projects/archives/
        echo "Archived: $2"
    elif [[ -d ~/projects/personal/"$1" ]]; then
        mv ~/projects/personal/"$1" ~/projects/archives/
        echo "Archived: $1"
    else
        echo "Project not found" >&2
        return 1
    fi
}

# NVM (load only if installed)
[[ -f /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh

# Machine-specific overrides (tokens, env vars, VPN aliases)
# Create ~/.config/zsh/user.local.zsh for per-machine config (gitignored)
[[ -f "${ZDOTDIR:-$HOME/.config/zsh}/user.local.zsh" ]] && \
    source "${ZDOTDIR:-$HOME/.config/zsh}/user.local.zsh"
