eval "$(/opt/homebrew/bin/brew shellenv zsh)"

# Nix packages before brew in PATH
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$PATH"
