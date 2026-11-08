eval "$(starship init zsh)"
fastfetch
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
setopt sharehistory
export PATH=$HOME/.local/bin:$PATH

[ -f ~/.config/zsh/homelab.zsh ] && source ~/.config/zsh/homelab.zsh
