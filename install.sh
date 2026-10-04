#!/usr/bin/env bash
# First-time setup of a new Mac. Safe to re-run: completed steps are skipped.
set -euo pipefail

DOTFILES="$HOME/dotfiles"

step() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
skip() { printf '    \033[2m%s, skipping\033[0m\n' "$*"; }
die() { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

# The path is hardcoded in home.nix (mkOutOfStoreSymlink)
[[ "$(cd "$(dirname "$0")" && pwd)" == "$DOTFILES" ]] ||
  die "the repo must be cloned to $DOTFILES"

# user.nix must describe this machine
grep -q "username = \"$USER\"" "$DOTFILES/user.nix" ||
  die "set username = \"$USER\" in user.nix and run again"
host="$(scutil --get LocalHostName)"
grep -q "hostname = \"$host\"" "$DOTFILES/user.nix" ||
  die "set hostname = \"$host\" in user.nix and run again"

step "Nix"
if command -v nix >/dev/null || [[ -e /nix/var/nix/profiles/default/bin/nix ]]; then
  skip "already installed"
else
  sh <(curl -L https://nixos.org/nix/install)
fi
# Load nix into the current shell
if ! command -v nix >/dev/null; then
  set +u
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  set -u
fi

step "Homebrew"
if [[ -x /opt/homebrew/bin/brew ]]; then
  skip "already installed"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

step "Files in /etc that nix-darwin will manage"
for f in /etc/nix/nix.conf /etc/zshrc /etc/bashrc /etc/zprofile; do
  # After the first switch these are symlinks to /etc/static; leave them alone
  if [[ -f "$f" && ! -L "$f" && ! -e "$f.before-nix-darwin" ]]; then
    sudo mv "$f" "$f.before-nix-darwin"
    echo "    $f → $f.before-nix-darwin"
  else
    skip "$f"
  fi
done

step "darwin-rebuild switch"
if command -v darwin-rebuild >/dev/null; then
  sudo darwin-rebuild switch --flake "$DOTFILES"
else
  sudo nix --extra-experimental-features 'nix-command flakes' \
    run nix-darwin/master#darwin-rebuild -- switch --flake "$DOTFILES"
fi

step "Rust toolchain"
# rustup comes from nix; the toolchain itself lives in ~/.rustup and is managed by rustup.
# PATH in this shell predates the switch, so call it by its profile path.
rustup="/etc/profiles/per-user/$USER/bin/rustup"
if "$rustup" default >/dev/null 2>&1; then
  skip "default toolchain is set"
else
  "$rustup" default stable
fi

step "Secrets file (~/.zshrc.local)"
if [[ -e "$HOME/.zshrc.local" ]]; then
  skip "already exists"
else
  # ~/.zshrc is a symlink into this repo, so tokens must not go there
  cat > "$HOME/.zshrc.local" <<'LOCAL'
# Secrets and machine-specific settings. Not in the dotfiles repo, never commit it.
# export FORGEJO_TOKEN=
# Work VPN (bin/sstp)
# export SSTP_USER= SSTP_PASSWORD= SSTP_SERVER=host:port SSTP_ROUTES="net/mask ..."
LOCAL
  chmod 600 "$HOME/.zshrc.local"
  echo "    created; put tokens there"
fi

step "Done. Restart the terminal."
