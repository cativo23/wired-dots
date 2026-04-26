# wired-dots — zsh entry point (sourced when ZDOTDIR points here)

# History
HISTFILE="${ZDOTDIR:-$HOME/.config/zsh}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Vi keys
bindkey -e

# Project / tool aliases + functions
[[ -f "${ZDOTDIR:-$HOME/.config/zsh}/user.zsh" ]] && \
    source "${ZDOTDIR:-$HOME/.config/zsh}/user.zsh"

# Starship prompt (init last so it overrides any earlier PROMPT)
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"
