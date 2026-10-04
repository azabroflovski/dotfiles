{ pkgs, user, ... }:

{
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${user.username}.home = "/Users/${user.username}";
  system.primaryUser = user.username;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "@admin" ];
  };
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 14d";
  };

  # Disabled: macOS (TCC) blocks writes to /etc/pam.d unless the terminal has Full Disk Access
  # security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.enable = false;

  # GUI apps via Homebrew (brew itself is installed separately, see install.sh)
  homebrew = {
    enable = true;
    onActivation = {
      # Upgrades only via `nup`, not on every rebuild
      autoUpdate = false;
      upgrade = false;
      # uninstalls everything not listed below
      cleanup = "uninstall";
    };
    taps = [ "nikitabobko/tap" ];
    brews = [ "sstp-client" ]; # SSTP VPN, see bin/sstp (not in nixpkgs for darwin)
    casks = [
      "nikitabobko/tap/aerospace"
      "claude-code"
      "google-chrome"
      "telegram"
    ];
  };

  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false; # aerospace: don't reorder spaces
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv"; # list view
    };
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
  };

  # Border around the focused window (handy with aerospace tiling); runs as a launchd agent
  services.jankyborders = {
    enable = true;
    active_color = "0xff5f8787"; # bathory accent
    inactive_color = "0x00000000";
    width = 5.0;
    style = "round";
    hidpi = true;
  };

  # Nerd Font for LazyVim icons
  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  # Profile dirs that plain config files source:
  # nix-direnv from config/direnv/direnvrc, zsh plugins from zsh/.zshrc
  environment.pathsToLink = [
    "/share/nix-direnv"
    "/share/zsh-autosuggestions"
    "/share/zsh-syntax-highlighting"
  ];

  # zsh comes from macOS; nix-darwin only adds the nix environment to /etc/zshrc
  programs.zsh.enable = true;

  # Don't change.
  system.stateVersion = 6;
}
