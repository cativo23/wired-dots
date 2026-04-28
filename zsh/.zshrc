# wired-dots — zsh entry point (sourced when ZDOTDIR=$HOME/.config/zsh)
#
# Source order — earlier wins on PATH/PROMPT, later wins on aliases:
#   1. wired-defaults.zsh   wired-dots-managed; refreshed on every install
#   2. user.zsh             user-owned; copied once on first install
#   3. user.local.zsh       gitignored; machine-specific (sourced from user.zsh)

# History
HISTFILE="${ZDOTDIR:-$HOME/.config/zsh}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Emacs keybindings (zsh default; explicit so themes/users see the choice).
bindkey -e

# Wired-managed framework defaults (always synced)
[[ -f "${ZDOTDIR:-$HOME/.config/zsh}/wired-defaults.zsh" ]] && \
    source "${ZDOTDIR:-$HOME/.config/zsh}/wired-defaults.zsh"

# User-owned config (one-time copy on install; user.local.zsh sourced from here)
[[ -f "${ZDOTDIR:-$HOME/.config/zsh}/user.zsh" ]] && \
    source "${ZDOTDIR:-$HOME/.config/zsh}/user.zsh"

# Starship prompt (init last so it overrides any earlier PROMPT)
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
