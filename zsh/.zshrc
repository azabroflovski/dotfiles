export EDITOR=nvim

# Own scripts from the repo
path=(~/dotfiles/bin $path)

# Completions and prompt from nix packages
fpath+=("/etc/profiles/per-user/$USER/share/zsh/site-functions")
autoload -U compinit; compinit
autoload -U promptinit; promptinit
prompt pure

eval "$(zoxide init zsh)"
source <(fzf --zsh)
# After fzf so atuin takes Ctrl-R; fzf keeps Ctrl-T and Alt-C
eval "$(atuin init zsh --disable-up-arrow)"
eval "$(direnv hook zsh)"

source "/etc/profiles/per-user/$USER/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

alias ls="eza"
alias ll="eza -la"
alias cat="bat --paging=never"
alias vim="nvim"
# Return darwin-rebuild's exit code, not nom's
rebuild() { sudo darwin-rebuild switch --flake ~/dotfiles |& nom; return ${pipestatus[1]}; }
# Second Claude Code with its own login, settings and history (work account); `claude` stays personal
alias claude-work="CLAUDE_CONFIG_DIR=~/.claude-work claude"

# Open configs (in a subshell, so the current directory stays put)
alias dots="(cd ~/dotfiles && nvim)"
alias zshrc="nvim ~/dotfiles/zsh/.zshrc"
alias nvimrc="(cd ~/dotfiles/config/nvim && nvim)"

alias nup="nix flake update --flake ~/dotfiles && rebuild && brew update && brew upgrade"
alias ngc="sudo nix-collect-garbage -d"
# Run a package without installing it: `try cowsay`
try() { nix shell "nixpkgs#$1"; }

# Attach to the tmux session named after the current directory, or create it
t() { tmux new -A -s "${1:-${PWD:t}}"; }

alias ports="lsof -iTCP -sTCP:LISTEN -nP"
alias reload="exec zsh"
alias lt="eza --tree --level=2 --git-ignore"
mkcd() { mkdir -p "$1" && cd "$1"; }

alias dc="docker compose"
alias iexm="iex -S mix"

# Secrets and machine-specific settings (tokens etc.). Lives outside the repo, never commit it
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Show off on a fresh terminal window, but not in tmux panes, nvim terminals or nested shells
if [[ -z $TMUX && -z $NVIM && $SHLVL -eq 1 ]]; then
  fastfetch
fi

# Must be sourced last
source "/etc/profiles/per-user/$USER/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
